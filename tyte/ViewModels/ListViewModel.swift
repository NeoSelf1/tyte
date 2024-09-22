import Foundation
import Combine
import Alamofire
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var weekCalendarData: [DailyStat] = []
    @Published var selectedDate :Date { didSet { fetchTodosForDate(selectedDate.apiFormat) } }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    private let todoService: TodoService
    private let dailyStatService: DailyStatService
    private let sharedVM: SharedTodoViewModel

    init(
        todoService: TodoService = TodoService(),
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
                print("Todo Creation Detected from ListViewModel")
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? Date().koreanDate.apiFormat)
                self?.fetchWeekCalendarData()
            }
            .store(in: &cancellables)
    }
    
    func scrollToToday(proxy: ScrollViewProxy? = nil) {
        withAnimation {
            selectedDate = Date().koreanDate
            print("scroll\(Date().koreanDate)")
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
                guard let self = self else { return }
                sharedVM.todosForDate = todos
                sharedVM.updateTodosInHome(with: todos)
            }
            .store(in: &cancellables)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchWeekCalendarData() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dailyStats in
                guard let self = self else { return }
                self.weekCalendarData = dailyStats
            }
            .store(in: &cancellables)
    }
}
