import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedTags: [String] = []
    
    @Published var sortOption: String = "default"
    @Published var currentTab: Int = 1
    
    private let sharedVM: SharedTodoViewModel
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        sharedVM: SharedTodoViewModel
    ) {
        self.sharedVM = sharedVM
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
        sharedVM.fetchAllTodos(mode: option)
    }
}
