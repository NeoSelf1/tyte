import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var inProgressTodos: [Todo] = []
    @Published var completedTodos: [Todo] = []
    
    @Published var tags: [Tag] = []
    @Published var selectedTags: [String] = []
    
    @Published var sortOption: String = "default"
    @Published var currentTab: Int = 0
    
    private let todoService: TodoService
    private let tagService: TagService
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todoService: TodoService = TodoService(),
        tagService: TagService = TagService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
        fetchTags()
    }
    
    func setupBindings(sharedVM: SharedTodoViewModel) {
        print("setupBindings in HomeViewModel")
        // SharedTodoViewModel의 allTodos가 변경될 때마다 totalTodos를 업데이트
        sharedVM.$lastAddedTodoId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                self?.fetchTodos(mode: self?.sortOption ?? "default")
            }
            .store(in: &cancellables)
    }
    
    func fetchTodos(mode: String = "default") {
        isLoading = true
        errorMessage = nil
        print("fetchTodos")
        todoService.fetchAllTodos(mode: mode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.inProgressTodos = todos.filter { !$0.isCompleted }
                self?.completedTodos = todos.filter { $0.isCompleted }
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
    
    func toggleTodo(_ id: String) {
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                
                if updatedTodo.isCompleted {
                    // Todo가 완료됨: inProgressTodos에서 제거하고 completedTodos에 추가
                    if let index = self.inProgressTodos.firstIndex(where: { $0.id == id }) {
                        _ = self.inProgressTodos.remove(at: index)
                        self.completedTodos.append(updatedTodo)
                    }
                } else {
                    // Todo가 미완료됨: completedTodos에서 제거하고 inProgressTodos에 추가
                    if let index = self.completedTodos.firstIndex(where: { $0.id == id }) {
                        _ = self.completedTodos.remove(at: index)
                        self.inProgressTodos.append(updatedTodo)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func setSortOption(_ option: String) {
        sortOption = option
        fetchTodos(mode: option)
    }
}
