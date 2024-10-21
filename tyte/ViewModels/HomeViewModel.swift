import Foundation
import Combine
import Alamofire
import SwiftUI

class HomeViewModel: ObservableObject {
    let appState = AppState.shared
    
    @Published var weekCalendarData: [DailyStat] = []
    @Published var todosForDate: [Todo] = []
    @Published var selectedDate :Date { didSet { fetchTodosForDate(selectedDate.apiFormat) } }
    @Published var tags: [Tag] = []
    @Published var isLoading: Bool = false
    
    @Published var isCreateTodoPresented: Bool = false
    @Published var isDetailPresented: Bool = false
    
    private let todoService: TodoService
    private let dailyStatService: DailyStatService
    private let tagService: TagService
    
    init(
        todoService: TodoService = TodoService.shared,
        dailyStatService: DailyStatService = DailyStatService.shared,
        tagService: TagService = TagService.shared
    ) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.tagService = tagService
        self.selectedDate = Date().koreanDate
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func scrollToToday(proxy: ScrollViewProxy? = nil) {
        withAnimation {
            selectedDate = Date().koreanDate
            fetchTodosForDate(selectedDate.apiFormat)
            if let proxy = proxy {
                proxy.scrollTo(Calendar.current.startOfDay(for: selectedDate), anchor: .center)
            }
        }
    }
    
    func addTodo(_ text: String) {
        isLoading = true
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    switch error {
                    case .invalidTodo:
                        appState.currentPopup = .invalidTodo
                    default:
                        appState.currentPopup = .error(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] newTodos in
                self?.isLoading = false
                guard let self = self else { return }
                if newTodos.count == 1 {
                    appState.currentPopup = .todoAddedIn(newTodos[0].deadline)
                } else {
                    appState.currentPopup = .todosAdded(newTodos.count)
                }
                self.fetchTodosForDate(self.selectedDate.apiFormat)
                self.fetchWeekCalendarData()
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        todosForDate = []
        isLoading = true
        todoService.fetchTodosForDate(deadline: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    func toggleTodo(_ id: String) {
        // MARK: Guard를 사용할 경우, 조기 반환, 옵셔널 바인딩 언래핑, 조건에 사용한 let 변수에 대한 스코프 확장이 가능.
        guard let index = todosForDate.firstIndex(where: { $0.id == id }) else { return }
        todosForDate[index].isCompleted.toggle()
        
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.currentPopup = .error(error.localizedDescription)
                    todosForDate[index].isCompleted.toggle()
                }
            } receiveValue: { [weak self] updatedTodo in
                self?.fetchWeekCalendarData()
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchWeekCalendarData() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.currentPopup = .error(error.localizedDescription)
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
                    appState.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                appState.currentPopup = .todoDeleted
                fetchTodosForDate(selectedDate.apiFormat)
                fetchWeekCalendarData()
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
                    appState.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] updatedTodoId in
                guard let self = self else { return }
                fetchTodosForDate(selectedDate.apiFormat)
                fetchWeekCalendarData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tag 관련 메서드
    func fetchTags() {
        isLoading = true
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.appState.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
}
