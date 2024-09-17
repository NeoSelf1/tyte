import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var totalTodos: [Todo] = []
    
    @Published var tags: [Tag] = []
    @Published var selectedTags: [String] = []
    
    @Published var sortOption: String = "default"
    @Published var currentTab: Int = 0
    
    private let todoService: TodoService
    private let tagService: TagService

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    var inProgressTodos: [Todo] {
           totalTodos.filter { !$0.isCompleted }
       }
       
       var completedTodos: [Todo] {
           totalTodos.filter { $0.isCompleted }
       }
    
    init(todoService: TodoService = TodoService(), tagService: TagService = TagService()) {
        self.todoService = todoService
        self.tagService = tagService
        self.setupInitialFetch()
    }

    private func setupInitialFetch() {
        fetchTodos()
        fetchTags()
    }

    func fetchTodos(mode: String = "default") {
        isLoading = true
        errorMessage = nil
        todoService.fetchAllTodos(mode: mode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.totalTodos = todos
            }
            .store(in: &cancellables)
    }

    func fetchTags() {
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
                var tagIds = tags.map { $0.id }
                tagIds.append("default")
                self?.selectedTags = tagIds
            }
            .store(in: &cancellables)
    }

    func toggleTag(id: String) {
        if let index = selectedTags.firstIndex(of: id) {
            if selectedTags.count > 1 {
                selectedTags.remove(at: index)
            }
        } else {
            selectedTags.append(id)
        }
    }
    
    //MARK: Todo 추가
    func addTodo(_ text: String) {
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchWeekCalenderData()
            }
            .store(in: &cancellables)
    }
    
    func toggleTodo(_ id: String) {
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTodo in
                if let index = self?.totalTodos.firstIndex(where: { $0.id == id }) {
                    self?.totalTodos[index] = updatedTodo
                }
            }
            .store(in: &cancellables)
    }

    func setSortOption(_ option: String) {
        sortOption = option
        fetchTodos(mode: option)
    }
}
