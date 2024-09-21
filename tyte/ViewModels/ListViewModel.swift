import Foundation
import Combine
import Alamofire
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var todosForDate: [Todo] = []
    @Published var weekCalendarData: [DailyStat] = []
    
    @Published var tags: [Tag] = []
    @Published var selectedDate :Date {
        didSet {
            todosForDate=[]
            print(selectedDate.koreanDate.apiFormat)
            fetchTodosForDate(selectedDate.apiFormat)
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    private let todoService: TodoService
    private let tagService: TagService
    private let dailyStatService: DailyStatService

    init(
        todoService: TodoService = TodoService(),
        dailyStatService: DailyStatService = DailyStatService(),
        tagService: TagService = TagService()
    ) {
        self.todoService = todoService
        self.dailyStatService = dailyStatService
        self.tagService = tagService
        self.selectedDate = Date().koreanDate
    }
    
    func setupBindings(sharedVM: SharedTodoViewModel) {
        sharedVM.$lastAddedTodoId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Todo Creation Detected from ListViewModel")
                self?.fetchTodosForDate(self?.selectedDate.apiFormat ?? Date().koreanDate.apiFormat)
            }
            .store(in: &cancellables)
        
        sharedVM.$lastUpdatedTagId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Tag Update Detected from ListViewModel")
                self?.fetchTags()
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
    
    func fetchTags() {
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
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
    func fetchWeekCalenderData() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("failure")
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
        // MARK: Guard를 사용할 경우, 조기 반환, 옵셔널 바인딩 언래핑, 조건에 사용한 let 변수에 대한 스코프 확장이 가능.
        guard let index = todosForDate.firstIndex(where: { $0.id == id }) else { return }
        todosForDate[index].isCompleted.toggle()
        
        todoService.toggleTodo(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    self.errorMessage = error.localizedDescription
                    self.todosForDate[index].isCompleted.toggle()
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
