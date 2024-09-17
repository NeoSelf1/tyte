import Foundation
import Combine
import Alamofire


class ListViewModel: ObservableObject {
    @Published var todosForDate: [Todo] = []
    @Published var weekCalenderData: [DailyStat_DayView] = []
    
    @Published var selectedDate :Date = Date()
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let todoService: TodoService
    private let dailyStatService: DailyStatService

    init(
        todoService: TodoService = TodoService(),
        dailyStatService: DailyStatService = DailyStatService()
    ) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.selectedDate = Date()
        self.fetchData()
    }
    
    func setupBindings(sharedVM: SharedTodoViewModel) {
        sharedVM.$lastAddedTodoId
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.fetchData()
            }
            .store(in: &cancellables)
        
        $selectedDate
            .sink { [weak self] _ in
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? Date().apiFormat)
            }
            .store(in: &cancellables)
    }
    
    private func fetchData() {
        fetchTodosForDate(selectedDate.apiFormat)
        fetchWeekCalenderData()
        
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
    func fetchWeekCalenderData() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dailyStats in
                let convertedStats = dailyStats.map { dailyStat -> DailyStat_DayView in
                    return DailyStat_DayView(
                        date: dailyStat.date,
                        balanceData: dailyStat.balanceData,
                        tagStats: dailyStat.tagStats,
                        center: dailyStat.center
                    )
                }
                self?.weekCalenderData = convertedStats
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 토글
    func toggleTodo(_ id: String) {
        print("toggleTodo")
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTodo in
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
                self?.fetchWeekCalenderData()
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
                self?.fetchWeekCalenderData()
            }
            .store(in: &cancellables)
    }
}