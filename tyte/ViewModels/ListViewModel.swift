import Foundation
import Combine
import Alamofire
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var weekCalendarData: [DailyStat] = []
    @Published var selectedDate :Date { didSet { fetchTodosForDate(selectedDate.apiFormat) } }
    
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private let todoService: TodoService
    private let dailyStatService: DailyStatService
    private let sharedVM: SharedTodoViewModel
    
    init(
        todoService: TodoService = TodoService.shared,
        dailyStatService: DailyStatService = DailyStatService(),
        sharedVM: SharedTodoViewModel
    ) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.selectedDate = Date().koreanDate
        self.sharedVM = sharedVM
    }
    
    func setupBindings(sharedVM: SharedTodoViewModel) {
        sharedVM.$lastAddedTodoId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? Date().koreanDate.apiFormat)
                self?.fetchWeekCalendarData()
            }
            .store(in: &cancellables)
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
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        sharedVM.todosForDate = []
        isLoading = true
        todoService.fetchTodosForDate(deadline: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    sharedVM.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                sharedVM.todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    func toggleTodo(_ id: String) {
        // MARK: Guard를 사용할 경우, 조기 반환, 옵셔널 바인딩 언래핑, 조건에 사용한 let 변수에 대한 스코프 확장이 가능.
        guard let index = sharedVM.todosForDate.firstIndex(where: { $0.id == id }) else { return }
        sharedVM.todosForDate[index].isCompleted.toggle()
        
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    sharedVM.currentPopup = .error(error.localizedDescription)
                    sharedVM.todosForDate[index].isCompleted.toggle()
                }
            } receiveValue: { [weak self] updatedTodo in
                guard let self = self else { return }
                sharedVM.updateTodoGlobal(updatedTodo)
                fetchWeekCalendarData()
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
                    sharedVM.currentPopup = .error(error.localizedDescription)
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
                    sharedVM.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                sharedVM.currentPopup = .todoDeleted
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
                    sharedVM.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] updatedTodoId in
                guard let self = self else { return }
                fetchTodosForDate(selectedDate.apiFormat)
                fetchWeekCalendarData()
            }
            .store(in: &cancellables)
    }
}
