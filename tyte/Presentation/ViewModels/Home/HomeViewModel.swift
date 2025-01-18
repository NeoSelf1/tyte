
/// - Note:MainActor.run 또한 async 메서드로 내부적으로 선언되어있음.
/// - 동기 메서드일 경우, 메인스레드가 다른 작업 수행으로 인해 전환이 지연될때, 스레드 전환 간 현재 스레드를 블록해야하는데, 이는 프로세스가 자원을 얻지 못해 다음 처리를 하지 못하는 상태인 데드락으로 이어질 수 있음.
/// - 하지만 비동기로 설계하면 필요한 경우 실행을 일시 중단하고 나중에 재개 가능.
/// - Note:``Task`` 블록은 백그라운드 스레드에서 실행될 수 있습니다.
///  따라서,``Task`` 내부에서의 네트워크 호출 후 UI 업데이트를 위해서는 명시적으로 메인스레드로의 전환이 필요합니다.
///
/// - ``@MainActor``를 통해 선언된 클래스 내부 모든 UI 관련 작업이 메인 스레드에서 실행되도록 명시할 수 있음 =  UI 관련 작업의 직렬화된 실행을 보장하는 메커니즘

import Foundation
import SwiftUI

enum DataType {
    case all(String) /// date.apiFormat
    case tag
    case todo(String) /// date.apiFormat
    case monthlyStat(String) /// date.apiFormat
}

@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - UI State
    
    @Published var weekCalendarData: [DailyStat] = []
    @Published var todosForDate: [Todo] = []
    @Published var tags: [Tag] = []

    @Published var selectedDate: Date = Date().koreanDate
    @Published var selectedTodo: Todo?

    @Published var isLoading: Bool = false
    @Published var isMonthPickerPresented: Bool = false
    @Published var isCreateTodoPresented: Bool = false
    @Published var isDetailPresented: Bool = false
    
    // MARK: - UseCases
    
    private let todoUseCase: TodoUseCaseProtocol
    private let tagUseCase: TagUseCaseProtocol
    private let dailyStatUseCase: DailyStatUseCaseProtocol
    
    init(
        todoUseCase: TodoUseCaseProtocol = TodoUseCase(),
        tagUseCase: TagUseCaseProtocol = TagUseCase(),
        dailyStatUseCase: DailyStatUseCaseProtocol = DailyStatUseCase()
    ) {
        self.todoUseCase = todoUseCase
        self.tagUseCase = tagUseCase
        self.dailyStatUseCase = dailyStatUseCase
        
        initialize()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        Task {
            await fetchData(.all(selectedDate.apiFormat))
        }
    }
    
    func setDateToTodayAndScrollCalendar(_ proxy: ScrollViewProxy? = nil) {
        let today = Date().koreanDate
        selectDate(today)
        
        if let proxy = proxy {
            proxy.scrollTo(Calendar.current.startOfDay(for: today), anchor: .center)
        }
    }
    
    func selectTodo(_ todo: Todo) {
        if todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate) {
            ToastManager.shared.show(.invalidTodoEdit)
        } else {
            Task {
                await fetchData(.tag)
                selectedTodo = todo
                isDetailPresented = true
            }
        }
    }
    
    func handleRefresh() {
        Task {
            await fetchData(.todo(selectedDate.apiFormat))
        }
    }
    
//    func handleRefresh() async {
//        await fetchData(.todo(selectedDate.apiFormat))
//    }
    
    func selectDate(_ date: Date) {
        guard date != selectedDate else { return }
        selectedDate = date
        
        Task {
            await fetchData(.todo(selectedDate.apiFormat))
        }
    }
    
    func addTodo(_ text: String) {
        /// - Note:Task 블록은 백그라운드 스레드에서 실행될 수 있습니다.
        Task {
            isLoading = true
            /// 현재 코드 블록이 종료될 때 실행될 코드를 지정하는 키워드입니다. return, throw, break 등으로 블록을 벗어나도 실행됩니다.
            defer { isLoading = false }
            
            let today = Date().koreanDate
            let dateToUse = selectedDate < today ? today.apiFormat : selectedDate.apiFormat
            
            do {
                // await는 비동기 작업이 완료될 때까지 현재 실행 컨텍스트를 일시 중단함으로써, 일시 중단될 수 있는 지점을 명확히 표시합니다.
                /// await와 함께 사용되는 try를 통해 비동기 작업에서 발생할 수 있는 에러 처리 지점도 명확하게 표시됩니다
                let (newTodos,updatedStat) = try await todoUseCase.createTodo(text: text, deadline: dateToUse)
                
                if selectedDate >= today {
                    todosForDate.insert(contentsOf: newTodos, at: 0)
                }
                
                if let stat = updatedStat {
                    if let index = self.weekCalendarData.firstIndex(where: { $0.date == dateToUse }) {
                        weekCalendarData[index] = stat
                    } else {
                        weekCalendarData.append(stat)
                    }
                }
                
                /// UI 로직은 Presentation 레이어에서 진행
                ToastManager.shared.show(newTodos.count == 1 ? .todoAddedIn(newTodos[0].deadline) : .todosAdded(newTodos.count))
                
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            } catch {
                print("Add Todo error: \(error)")
            }
        }
    }
    
    func toggleTodo(_ todo: Todo) {
        let originalState = todo.isCompleted
        Task {
            do {
                /// 낙관적 렌더링
                if let index = todosForDate.firstIndex(where: { $0.id == todo.id }) {
                    todosForDate[index].isCompleted.toggle()
                }
                
                let updatedStat = try await todoUseCase.toggleTodo(todo)
                
                guard let stat = updatedStat else { return }
                if let index = weekCalendarData.firstIndex(where: {stat.date == $0.date}) {
                    withAnimation { weekCalendarData[index] = stat }
                } else {
                    withAnimation { weekCalendarData.append(stat) }
                }
            } catch {
                print("Toggle Todo error: \(error)")
                if let index = todosForDate.firstIndex(where: { $0.id == todo.id }) {
                    todosForDate[index].isCompleted = originalState
                }
            }
            
        }
    }
    
    func editTodo(_ todo: Todo) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let updatedStats = try await todoUseCase.updateTodoWithStats(todo,from: selectedDate.apiFormat)
                
                /// 변경된 Todo가 선택된 날짜에 있을 경우, 상태변수를 직접 조작해 당장 보이는 UI를 업데이트합니다.
                /// - Note: 선택된 날짜 외의 날짜로 Todo 위치가 변경되었을 경우, 날짜 변경 시점에 Todo들을 로컬 및 리모트로부터 새로 불러오기 때문에 추가 구현이 불요합니다.
                if let index = todosForDate.firstIndex(where: {$0.id == todo.id}) {
                    todosForDate[index] = todo
                }
                
                /// TodoRepository로부터 새로 가져온 일간 통계자료 2개를 순회하며, 동일 날짜에 통계 데이터가 존재할 경우 대체, 존재하지 않을 경우 append 합니다.
                /// - Note: 할일의 난이도, 생활여부에 따라 일간 통계자료가 nil로 반환돼, Presentation 레이어에서 빈 배열을 반환받을 수도 있습니다.
                /// - Note: DailyStat은 각자 고유한 date 속성을 갖고 있으며 이를 접근하기 위한 키로서 사용하고 있기 때문에 배열 간 순서 고려가 불필요합니다.
                for stat in updatedStats {
                    if let index = weekCalendarData.firstIndex(where: {stat.date == $0.date}) {
                        weekCalendarData[index] = stat
                    } else {
                        weekCalendarData.append(stat)
                    }
                }
                
                ToastManager.shared.show(.todoEdited)
            } catch {
                print("Edit Todo error: \(error)")
            }
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                /// - Note: 선택된 날짜에 대한 Todo만 삭제가 가능하기에, 예외 케이스없이 항상 최신 일간 통계 데이터를 반환받습니다.
                let updatedStat = try await todoUseCase.deleteTodo(todo)
                
                if let index = todosForDate.firstIndex(where: {$0.id == todo.id}) {
                    todosForDate.remove(at: index)
                }
                
                ToastManager.shared.show(.todoDeleted)
                
                guard let stat = updatedStat else { return }
                if let index = weekCalendarData.firstIndex(where: {stat.date == $0.date}) {
                    weekCalendarData[index] = stat
                } else {
                    weekCalendarData.append(stat)
                }
            } catch {
                print("Delete Todo error: \(error)")
            }
        }
    }
    
    /// MonthPicker에서 호출
    func changeMonth(_ currentYear: Int, _ currentMonth: Int) {
        let components = DateComponents(year: currentYear, month: currentMonth + 1, day: 1)
        if let newDate = Calendar.current.date(from: components) {
            selectDate(newDate)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchData(_ dataType: DataType) async {
        do {
            switch dataType {
            case .all(let date):
                async let todosTask = todoUseCase.getTodos(in: date)
                async let statsTask = dailyStatUseCase.getMonthStats(in: date)
                async let tagsTask = tagUseCase.getAllTags()
                
                // await를 한 번에 처리하여 병렬 실행
                (todosForDate, weekCalendarData, tags) = try await (todosTask, statsTask, tagsTask)
            case .todo(let date):
                todosForDate = try await todoUseCase.getTodos(in: date)
            case .monthlyStat(let date):
                weekCalendarData = try await dailyStatUseCase.getMonthStats(in: date)
            case .tag:
                tags = try await tagUseCase.getAllTags()
            }
        } catch {
            print("error refreshing \(dataType): \(error)")
        }
    }
}
