import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var totalTodos: [Todo] = []
    @Published var inProgressTodos: [Todo] = [] {didSet{print(inProgressTodos.debugDescription)}}
    @Published var completedTodos: [Todo] = []
    
    @Published var tags: [Tag] = []
    @Published var selectedTags: [String] = []
    
    @Published var sortOption: String = "default"
    @Published var currentTab: Int = 0
    
    private let todoService: TodoService
    private let tagService: TagService
    
    private let sharedTodoVM: SharedTodoViewModel


    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todoService: TodoService = TodoService(),
        tagService: TagService = TagService(),
        sharedTodoVM: SharedTodoViewModel
    ) {
        self.todoService = todoService
        self.tagService = tagService
        self.sharedTodoVM = sharedTodoVM
        setupBindings()
        fetchTags()
    }
    
    private func setupBindings() {
        print("setupBindings")
        // totalTodos가 변경될 때마다 inProgressTodos와 completedTodos 업데이트
        $totalTodos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                self?.inProgressTodos = todos.filter { !$0.isCompleted }
                self?.completedTodos = todos.filter { $0.isCompleted }
            }
            .store(in: &cancellables)
        
        // SharedTodoViewModel의 allTodos가 변경될 때마다 totalTodos를 업데이트
        sharedTodoVM.$allTodos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                self?.totalTodos = todos
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
