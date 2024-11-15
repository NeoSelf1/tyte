import Foundation
import Combine
import Alamofire
import SwiftUI

class HomeViewModel: ObservableObject {
    private let appState: AppState
    
    @Published var weekCalendarData: [DailyStat] = []
    @Published var todosForDate: [Todo] = []
    @Published var selectedTodo: Todo?
    @Published var tags: [Tag] = []
    @Published var selectedDate: Date = Date().koreanDate { didSet { fetchTodosForDate(selectedDate.apiFormat) } }
    
    @Published var isLoading: Bool = false
    @Published var isCreateTodoPresented: Bool = false
    @Published var isDetailPresented: Bool = false
    
    private let todoService: TodoServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    private let tagService: TagServiceProtocol
    
    init(
        todoService: TodoServiceProtocol = TodoService(),
        dailyStatService: DailyStatServiceProtocol = DailyStatService(),
        tagService: TagServiceProtocol = TagService(),
        appState: AppState = .shared
    ) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.tagService = tagService
        self.appState = appState
        
        fetchTags()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    func selectTodo(_ todo: Todo){
        selectedTodo = todo
        fetchTags()
        isDetailPresented = true
    }
    
    func scrollToToday(proxy: ScrollViewProxy? = nil) {
        withAnimation {
            selectedDate = Date().koreanDate
            fetchTodosForDate(selectedDate.apiFormat)
            
            if let proxy = proxy {
                proxy.scrollTo(Calendar.current.startOfDay(for: selectedDate), anchor: .center)
            }
        }
    }
    
    func changeMonth(_ currentYear: Int, _ currentMonth: Int) {
        let components = DateComponents(year: currentYear, month: currentMonth + 1, day: 1)
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
            fetchWeekCalendarData(newDate.apiFormat)
        }
    }
    
    func fetchInitialData () {
        fetchTodosForDate(selectedDate.apiFormat)
        fetchWeekCalendarData(selectedDate.apiFormat)
    }
    
    func addTodo(_ text: String) {
        isLoading = true
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] newTodos in
                guard let self = self else { return }
                isLoading = false
                
                if newTodos.count == 1 {
                    appState.showToast(.todoAddedIn(newTodos[0].deadline))
                } else {
                    appState.showToast(.todosAdded(newTodos.count))
                }
                
                fetchTodosForDate(selectedDate.apiFormat)
                fetchWeekCalendarData(selectedDate.apiFormat) // MARK: 일간 DailyStat 변경 api로 변경
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    private func fetchTodosForDate(_ deadline: String) {
        todosForDate = []
        isLoading = true
        todoService.fetchTodos(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    //MARK: 선택한 날짜가 포함된 달의 전체 일수에 대한 DailyStat을 weekCalendarData에 삽입
    private func fetchDailyStatForDate(_ deadline: String) {
        dailyStatService.fetchDailyStat(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] dailyStat in
                guard let self = self else { return }
                withAnimation(.mediumEaseInOut){
                    if let index = self.weekCalendarData.firstIndex(where: {$0.date == deadline}) {
                        self.weekCalendarData[index] = dailyStat
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleTodo(_ id: String) {
        // MARK: Guard를 사용할 경우, 조기 반환, 옵셔널 바인딩 언래핑, 조건에 사용한 let 변수에 대한 스코프 확장이 가능.
        guard let index = todosForDate.firstIndex(where: { $0.id == id } ) else { return }
        let originalState = todosForDate[index].isCompleted
        todosForDate[index].isCompleted.toggle()
        
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                    todosForDate[index].isCompleted = originalState
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                fetchDailyStatForDate(todosForDate[index].deadline)
            }
            .store(in: &cancellables)
    }
    
    //MARK: 선택한 날짜가 포함된 달의 전체 일수에 대한 DailyStat 반환
    private func fetchWeekCalendarData(_ date: String) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date.parsedDate)
        let startOfMonth = calendar.date(from: components)!
        let numberOfDays = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        let endOfMonth = calendar.date(byAdding: .day, value: numberOfDays - 1, to: startOfMonth)!
        
        dailyStatService.fetchMonthlyStats(range: "\(startOfMonth.apiFormat),\(endOfMonth.apiFormat)")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] dailyStats in
                guard let self = self else { return }
                withAnimation(.mediumEaseInOut){
                    self.weekCalendarData = dailyStats
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 삭제
    func deleteTodo(id: String) {
        todoService.deleteTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] deletedTodo in
                guard let self = self else { return }
                appState.showToast(.todoDeleted)
                fetchTodosForDate(deletedTodo.deadline) //TODO: todos에서 단순 제거하기
                fetchDailyStatForDate(deletedTodo.deadline)
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 수정
    func editTodo(_ todo: Todo) {
        todoService.updateTodo(todo: todo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                fetchTodosForDate(updatedTodo.deadline)
                fetchDailyStatForDate(updatedTodo.deadline)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tag 관련 메서드
    func fetchTags() {
        isLoading = true
        tagService.fetchTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
}
