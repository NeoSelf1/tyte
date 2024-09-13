import Foundation
import Combine
import Alamofire


class TagEditViewModel: ObservableObject {
    @Published var tags: [Tag] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let tagService: TagService
    
    init(tagService: TagService = TagService()) {
        self.tagService = tagService
        self.setupInitialFetch()
    }
    
    private func setupInitialFetch() {
        fetchTags()
    }
    
    //MARK: 모든 Tag 객체 fetch
    func fetchTags() {
        isLoading = true
        errorMessage = nil
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 추가
    func addTag(name: String, color: String) {
        tagService.createTag(name: name,color:color)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchTags()
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 삭제
    func deleteTag(id: String) {
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchTags()
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 수정
    func editTodo(_ tag: Tag) {
        tagService.updateTag(tag: tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchTags()
            }
            .store(in: &cancellables)
    }
}
