import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedTags: [String] = []
    
    @Published var sortOption: String = "default"
    @Published var currentTab: Int = 0
    
    private let todoService: TodoService 
    private let sharedVM: SharedTodoViewModel
    
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(
        sharedVM: SharedTodoViewModel,
        todoService: TodoService = TodoService()
    ) {
        self.sharedVM = sharedVM
        self.todoService = todoService
        fetchTodos()
        self.selectedTags = sharedVM.tags.map{$0.id}
    }
    
    var isAllTagsSelected: Bool {
        !selectedTags.isEmpty && selectedTags.count == sharedVM.tags.count + 1 // +1 for "default" tag
    }
    
    func selectAllTags() {
        selectedTags = (sharedVM.tags.map { $0.id } + ["default"])
    }
    
    func setupBindings(sharedVM: SharedTodoViewModel) {
        sharedVM.$lastAddedTodoId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Todo Creation Detected from Home")
                self?.fetchTodos()
            }
            .store(in: &cancellables)
        
        sharedVM.$tags
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tags in
                print(tags.description)
                guard let self = self else { return }
                    self.selectedTags = ["default"] + tags.map { $0.id }
            }
            .store(in: &cancellables)
    }
    
    // 값에 의존하는 상태가 변경될때마다 자동으로 재계산된다. 즉, currentTab 변경 시, inProgressTodos or completedTodos 배열 변경 시, selectedTags 배열 변경 시 ...
    var filteredTodos: [Todo] {
        let todos = currentTab == 0 ? sharedVM.inProgressTodos : sharedVM.completedTodos
        return todos.filter { todo in
            if selectedTags.contains("default") {
                return todo.tagId == nil || (todo.tagId != nil && selectedTags.contains(todo.tagId!.id))
            } else {
                return todo.tagId != nil && selectedTags.contains(todo.tagId!.id)
            }
        }
    }
    
    func fetchTodos() {
        isLoading = true
        errorMessage = nil
        todoService.fetchAllTodos(mode: sortOption)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    sharedVM.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                sharedVM.inProgressTodos = todos.filter { !$0.isCompleted }
                sharedVM.completedTodos = todos.filter { $0.isCompleted }
            }
            .store(in: &cancellables)
    }
    
    func toggleTodo(_ id: String) {
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    sharedVM.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                if updatedTodo.isCompleted {
                    // Todo가 완료됨: inProgressTodos에서 제거하고 completedTodos에 추가
                    if let index = sharedVM.inProgressTodos.firstIndex(where: { $0.id == id }) {
                        _ = sharedVM.inProgressTodos.remove(at: index)
                        sharedVM.completedTodos.append(updatedTodo)
                    }
                } else {
                    // Todo가 미완료됨: completedTodos에서 제거하고 inProgressTodos에 추가
                    if let index = sharedVM.completedTodos.firstIndex(where: { $0.id == id }) {
                        _ = sharedVM.completedTodos.remove(at: index)
                        sharedVM.inProgressTodos.append(updatedTodo)
                    }
                }
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
    
    func setSortOption(_ option: String) {
        sortOption = option
        fetchTodos()
    }
}
