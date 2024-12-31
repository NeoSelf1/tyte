import Foundation
import Combine
import Alamofire
import SwiftUI
import WidgetKit

class HomeViewModel: ObservableObject {
    @Published var weekCalendarData: [DailyStat] = []
    @Published var todosForDate: [Todo] = []
    @Published var tags: [Tag] = []
    
    @Published var selectedDate: Date = Date().koreanDate
    @Published var selectedTodo: Todo?
    
    @Published var isLoading: Bool = false
    
    @Published var isMonthPickerPresented: Bool = false
    @Published var isCreateTodoPresented: Bool = false
    @Published var isDetailPresented: Bool = false
    
    // TODO: Repository 패턴 도입
    private let syncService = CoreDataSyncService.shared
    
    init() {
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: - Method
    func initialize() {
        isLoading = true
        
        let today = Date().koreanDate
        
        readLocalData(type: .all, in: today)
        
        isLoading = false
        
        syncLatestData()
    }
    
    //selectedDate 오늘로 변경 (해당날짜 todos 자동 fetch) -> 오늘로 캘린더 이동
    func setDateToTodayAndScrollCalendar(_ proxy: ScrollViewProxy? = nil) {
        let today = Date().koreanDate
        
        changeDate(today)
        
        if let proxy = proxy {
            proxy.scrollTo(Calendar.current.startOfDay(for: today), anchor: .center)
        }
    }
    
    /// HomeView에서 Todo 선택
    func selectTodo(_ todo: Todo){
        if todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate){
            ToastManager.shared.show(.invalidTodoEdit)
        } else {
            selectedTodo = todo
            readLocalData(type: .tag, in: selectedDate)
            isDetailPresented = true
        }
    }
    
    /// HomeView에서 리스트 refresh 시 호출
    func handleRefresh(){
        refreshTodos(for:selectedDate.apiFormat)
    }
    
    /// DayView에서 호출
    func changeDate(_ date: Date){
        guard date != selectedDate else { return }
        
        readLocalData(type: .todo, in: date)
        
        refreshTodos(for: date.apiFormat)
        
        let currentYearMonth = selectedDate.apiFormat.prefix(7)
        let newYearMonth = date.apiFormat.prefix(7)
        
        if currentYearMonth != newYearMonth {
            readLocalData(type: .dailyStat, in: date)
            
            refreshMonthlyStats(for: date.apiFormat)
        }
        
        withAnimation(.fastEaseInOut){ selectedDate = date }
    }
    
    /// MonthPicker에서 호출
    func changeMonth(_ currentYear: Int, _ currentMonth: Int) {
        let components = DateComponents(year: currentYear, month: currentMonth + 1, day: 1)
        if let newDate = Calendar.current.date(from: components) {
            changeDate(newDate)
        }
    }
}


// MARK: - CRUD Method

extension HomeViewModel {
    /// Todo 추가
    func addTodo(_ text: String) {
        isLoading = true
        
        let today = Date().koreanDate
        let dateToUse = selectedDate < today ? today.apiFormat : selectedDate.apiFormat
        
        syncService.createTodo(text: text, in: dateToUse)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion, case .networkError = error as? APIError {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] newTodos in
                guard let self = self else { return }
                
                if newTodos.count == 1 {
                    ToastManager.shared.show(.todoAddedIn(newTodos[0].deadline))
                } else {
                    ToastManager.shared.show(.todosAdded(newTodos.count))
                }
                
                refreshTodos(for: selectedDate.apiFormat)
                // TODO: dailyStat 수정으로 대체한후, 위젯 업데이트 시점 dailyStat 수정으로 한정시키기
                refreshMonthlyStats(for: selectedDate.apiFormat)
                
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            .store(in: &cancellables)
    }
    
    /// Todo isCompleted 토글 / 낙관적 렌더 -> isLoading 붎필요
    func toggleTodo(_ todo: Todo) {
        guard let index = todosForDate.firstIndex(where: { $0.id == todo.id } ) else { return }
        let originalState = todosForDate[index].isCompleted
        todosForDate[index].isCompleted.toggle()
        
        syncService.updateTodo(todosForDate[index])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.todosForDate[index].isCompleted = originalState
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                refreshDailyStat(for: updatedTodo.deadline)
            }
            .store(in: &cancellables)
    }
    
    /// Todo 수정
    func editTodo(_ todo: Todo) {
        isLoading = true
        
        syncService.updateTodo(todo)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                ToastManager.shared.show(.todoEdited)
                
                // Refresh에서 read로 대체하여 네트워크 호출 수 줄이자.
                // refreshTodos(for: selectedDate.apiFormat)
                readLocalData(type: .todo, in: selectedDate)
                
                // 출발지점에 대한 dailyStat와 변경된 도착지에 대한 dailyStat 둘다 수정 필요
                refreshDailyStat(for: updatedTodo.deadline)
                refreshDailyStat(for: selectedDate.apiFormat)
            }
            .store(in: &cancellables)
    }
    
    /// Todo 삭제
    func deleteTodo(id: String) {
        isLoading = true
        
        syncService.deleteTodo(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
            } receiveValue: { [weak self] deletedTodoId in
                guard let self = self else { return }
                ToastManager.shared.show(.todoDeleted)
                todosForDate = todosForDate.filter{$0.id != deletedTodoId}
                refreshDailyStat(for: selectedDate.apiFormat)
            }
            .store(in: &cancellables)
    }
    
    
    //MARK: - 내부 함수
    
    private func syncLatestData() {
        syncService.refreshTags()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: {  [weak self] _tags in
                guard let self = self else { return }
                print(_tags)
                tags = _tags
                
                refreshTodos(for: selectedDate.apiFormat)
                refreshMonthlyStats(for: selectedDate.apiFormat)
            }
            .store(in: &cancellables)
    }
    
    // 특정 날짜에 대한 Todo들 fetch
    private func refreshTodos(for deadline: String) {
        syncService.refreshTodos(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: {  [weak self] todos in
                self?.todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    // 선택한 날짜에 대한 DailyStat을 weekCalendarData에 삽입
    private func refreshDailyStat(for deadline: String) {
        syncService.refreshDailyStat(for:deadline)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: {  [weak self] dailyStat in
                guard let self = self else { return }
                if let index = weekCalendarData.firstIndex(where: {$0.date == deadline}) {
                    withAnimation { self.weekCalendarData[index] = dailyStat ?? .empty }
                } else {
                    var newStats = self.weekCalendarData
                    newStats.append(dailyStat ?? .empty)
                    withAnimation { self.weekCalendarData = newStats.sorted { $0.date < $1.date } }
                }
            }
            .store(in: &cancellables)
    }
    
    
    //MARK: 선택한 날짜가 포함된 달의 전체 일수에 대한 DailyStat 반환
    private func refreshMonthlyStats(for date: String) {
        syncService.refreshDailyStats(for: String(date.prefix(7)))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("error in refreshMonthlyStats : \(error)")
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: {  [weak self] dailyStats in
                print("refreshMonthlyStats done")
                withAnimation { self?.weekCalendarData = dailyStats }
            }
            .store(in: &cancellables)
    }
    
    private func refreshTags() {
        syncService.refreshTags()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] _tags in
                self?.tags = _tags
            }
            .store(in: &cancellables)
    }
    
    private func readLocalData(type: LocalDataType, in date: Date) {
        switch type {
        case .all:
            if let localTags = try? syncService.readTagsFromStore() {
                tags = localTags
            }
            
            if let localTodos = try? syncService.readTodosFromStore(for: date.apiFormat) {
                todosForDate = localTodos
            }
            
            if let localDailyStats = try? syncService.readDailyStatsFromStore(for: String(date.apiFormat.prefix(7))) {
                weekCalendarData = localDailyStats
            }
        case .todo:
            if let localTodos = try? syncService.readTodosFromStore(for: date.apiFormat) {
                todosForDate = localTodos
            }
        case .tag:
            if let localTags = try? syncService.readTagsFromStore() {
                tags = localTags
            }
        case .dailyStat:
            if let localDailyStats = try? syncService.readDailyStatsFromStore(for: String(date.apiFormat.prefix(7))) {
                weekCalendarData = localDailyStats
            }
        }
    }
}

enum LocalDataType {
    case all
    case tag
    case todo
    case dailyStat
}
