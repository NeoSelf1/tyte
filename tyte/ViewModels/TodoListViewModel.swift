import Foundation
import Combine
import Alamofire


class TodoListViewModel: ObservableObject {
    @Published var totalTodos: [Todo] = []
    @Published var todosForDate: [Todo] = []
    @Published var dailyStats: [DailyStat] = []
    
    @Published var currentMonth: String // 추후 가로형 스크롤 피커에서 실시간 재렌더를 트리커하고자 생성.
    @Published var selectedDate :Date = Date() {
        didSet {
            todosForDate=[]
            fetchTodosForDate(selectedDate.apiFormat)
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let todoService: TodoService
    private let dailyStatService: DailyStatService
    
    init(todoService: TodoService = TodoService(), dailyStatService: DailyStatService = DailyStatService()) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.currentMonth = Date().formattedMonth
        self.selectedDate = Date()
        
        // 모든 프로퍼티 초기화 후 메서드 호출
        self.setupInitialFetch()
    }
    
    private func setupInitialFetch() {
        fetchTodosForDate(selectedDate.apiFormat)
        fetchTodos()
        // totalTodos에 대한 didSet 로직을 여기로 이동
        $totalTodos
            .dropFirst() // 초기값 무시
            .sink { [weak self] _ in
                if self?.dailyStats.isEmpty == true {
                    self?.fetchAllDailyStats()
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: 모든 투두 객체 fetch
    func fetchTodos(mode: String = "default") {
        isLoading = true
        errorMessage = nil
        todoService.fetchAllTodos(mode:mode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.totalTodos = todos
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        isLoading = true
        errorMessage = nil
        todoService.fetchTodosForDate(deadline: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchAllDailyStats() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dailyStats in
                self?.dailyStats = dailyStats
            }
            .store(in: &cancellables)
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
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? "")
                self?.fetchAllDailyStats()
                self?.fetchTodos()
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 토글
    func toggleTodo(_ id: String, isTotal: Bool) {
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
                if let index = self?.todosForDate.firstIndex(where: { $0.id == id }) {
                    self?.todosForDate[index] = updatedTodo
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 삭제
    func deleteTodo(id: String) {
        todoService.deleteTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? "")
                self?.fetchAllDailyStats()
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 수정
    func editTodo(_ todo: Todo) {
        todoService.updateTodo(todo: todo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? "")
                self?.fetchAllDailyStats()
            }
            .store(in: &cancellables)
    }
    
    private func updateMetrics() {
        print("UpdateMetrics Called")
    }
}
