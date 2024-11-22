import Foundation
import Combine
import Alamofire
import SwiftUI

class HomeViewModel: ObservableObject {
    private let appState: AppState
    @Published var isInitialized: Bool = false
    
    @Published var weekCalendarData: [DailyStat] = []
    @Published var todosForDate: [Todo] = []
    @Published var selectedTodo: Todo?
    @Published var tags: [Tag] = []
    @Published var selectedDate: Date = Date().koreanDate { didSet { getTodosForDate(selectedDate.apiFormat) } }
    
    @Published var isLoading: Bool = false
    @Published var isMonthPickerPresented:Bool = false
    @Published var isCreateTodoPresented: Bool = false
    @Published var isDetailPresented: Bool = false
    
    private let todoService: TodoServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    private let tagService: TagServiceProtocol // 투두 상세 바텀시트 클릭시, 선택지 부여위해 fetchTag 메서드 필요
    
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
        
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    
    func initialize() {
        getDailyStatsForMonth(selectedDate.apiFormat)
        //TODO: 임시방편임. 해결방안 도출할 것.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInitialized = true
        }
    }
    
    //selectedDate 오늘로 변경 (해당날짜 todos 자동 fetch) -> 오늘로 캘린더 이동
    func setDateToTodayAndScrollCalendar(_ proxy: ScrollViewProxy? = nil) {
        selectedDate = Date().koreanDate
        if let proxy = proxy {
            proxy.scrollTo(Calendar.current.startOfDay(for: selectedDate), anchor: .center)
        }
    }
    
    // Todo 선택
    func selectTodo(_ todo: Todo){
        // 이전 투두의 경우
        if todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate){
            appState.showToast(.invalidTodoEdit)
        } else {
            selectedTodo = todo
            getTags()
            isDetailPresented = true
        }
    }
    
    func handleRefresh(){
        getTodosForDate(selectedDate.apiFormat)
    }
    
    // DayView에서 호출
    func selectDate(_ date: Date){
        withAnimation(.fastEaseInOut){ selectedDate = date }
        getTodosForDate(date.apiFormat)
    }
    
    // MonthPicker에서 호출
    func changeMonth(_ currentYear: Int, _ currentMonth: Int) {
        let components = DateComponents(year: currentYear, month: currentMonth + 1, day: 1)
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
            getDailyStatsForMonth(newDate.apiFormat)
        }
    }
    
    // Todo 추가
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
                
                if newTodos.count == 1 {
                    appState.showToast(.todoAddedIn(newTodos[0].deadline))
                } else {
                    appState.showToast(.todosAdded(newTodos.count))
                }
                
                getTodosForDate(selectedDate.apiFormat)
                getDailyStatsForMonth(selectedDate.apiFormat)
                
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            .store(in: &cancellables)
    }
    
    // Todo isCompleted 토글 / MARK: isLoading 붎필요
    func toggleTodo(_ id: String) {
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
                getDailyStatForDate(todosForDate[index].deadline)
            }
            .store(in: &cancellables)
    }
    
    // Todo 삭제
    func deleteTodo(id: String) {
        isLoading = true
        todoService.deleteTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] deletedTodo in
                guard let self = self else { return }
                appState.showToast(.todoDeleted)
                todosForDate = todosForDate.filter{$0.id != deletedTodo.id}
                getDailyStatForDate(deletedTodo.deadline)
            }
            .store(in: &cancellables)
    }
    
    // Todo 수정
    func editTodo(_ todo: Todo) {
        isLoading = true
        todoService.updateTodo(todo: todo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                getTodosForDate(updatedTodo.deadline)
                getDailyStatForDate(updatedTodo.deadline)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 내부 함수
    // 특정 날짜에 대한 Todo들 fetch
    private func getTodosForDate(_ deadline: String) {
        isLoading = true
        todosForDate = []
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
    
    // 선택한 날짜에 대한 DailyStat을 weekCalendarData에 삽입
    private func getDailyStatForDate(_ deadline: String) {
        dailyStatService.fetchDailyStat(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    print(error)
                    // TODO: 백엔드에서 nil값 받을때, decode 에러 발생안하게 변경 필요
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] dailyStat in
                guard let self = self else { return }
                if let index = weekCalendarData.firstIndex(where: {$0.date == deadline}) {
                    withAnimation { self.weekCalendarData[index] = dailyStat ?? .empty }
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: 선택한 날짜가 포함된 달의 전체 일수에 대한 DailyStat 반환
    private func getDailyStatsForMonth(_ date: String) {
        dailyStatService.fetchMonthlyStats(in: String(date.prefix(7)))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] dailyStats in
                guard let self = self else { return }
                    withAnimation { self.weekCalendarData = dailyStats }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tag 관련 메서드
    func getTags() {
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
