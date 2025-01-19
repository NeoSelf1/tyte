protocol TodoUseCaseProtocol {
    func getTodos(in dateString: String) async throws -> [Todo]
    func getTodos(in dateString: String, for friendId: String) async throws -> [Todo]
    func createTodo(text: String, deadline: String) async throws -> ([Todo], DailyStat?)
    func updateTodoWithStats(_ todo: Todo, from originalDate: String) async throws -> ([DailyStat])
    func toggleTodo(_ todo: Todo) async throws -> DailyStat?
    func deleteTodo(_ todo: Todo) async throws -> DailyStat?
}

/// Todo 항목들을 관리하는 비즈니스 로직을 처리하는 Use Case입니다.
///
/// 다음과 같은 핵심 기능을 제공합니다:
/// - Todo 생성, 수정, 삭제, 조회
/// - Todo 완료 상태 토글
/// - DailyStat 자동 업데이트 처리
///
/// ## 사용 예시
/// ```swift
/// let todoUseCase = TodoUseCase()
///
/// // Todo 생성
/// let (newTodos, updatedStat) = try await todoUseCase.createTodo(
///     text: "회의 준비하기",
///     deadline: "2024-01-20"
/// )
/// ```
///
/// ## 관련 타입
/// - ``TodoRepositoryProtocol``
/// - ``DailyStatRepositoryProtocol``
/// - ``Todo``
/// - ``DailyStat``
///
/// - Note: Clean Architecture의 Use Case 계층에 속하며, Repository 패턴을 통해 데이터 접근을 추상화합니다.
/// - SeeAlso: ``DailyStatUseCase``, ``TagUseCase``
class TodoUseCase: TodoUseCaseProtocol {
    private let todoRepository: TodoRepositoryProtocol
    private let dailyStatRepository: DailyStatRepositoryProtocol
        
    init(
        todoRepository: TodoRepository = TodoRepository(),
        dailyStatRepository: DailyStatRepository = DailyStatRepository()
    ) {
        self.todoRepository = todoRepository
        self.dailyStatRepository = dailyStatRepository
    }
    
    func getTodos(in dateString: String) async throws -> [Todo] {
        return try await todoRepository.get(in: dateString)
    }
    
    func getTodos(in dateString: String, for friendId: String) async throws -> [Todo] {
        return try await todoRepository.get(in: dateString, for: friendId)
    }

   
    func createTodo(text: String, deadline: String) async throws -> ([Todo], DailyStat?) {
        let createdTodos = try await todoRepository.create(text: text, in: deadline)
        let updatedStat = try await dailyStatRepository.getSingle(for: deadline)
        
        WidgetManager.shared.updateWidget(.all)
        return (createdTodos, updatedStat)
    }
    
    func updateTodoWithStats(_ todo: Todo, from originalDate: String) async throws -> ([DailyStat]) {
        try await todoRepository.updateSingle(todo)
        
        let updatedStat1 = try await dailyStatRepository.getSingle(for: originalDate)
        let updatedStat2 = try await dailyStatRepository.getSingle(for: todo.deadline)

        WidgetManager.shared.updateWidget(.all)
        
        return [updatedStat1, updatedStat2].compactMap{$0}
    }
    
    func deleteTodo(_ todo: Todo) async throws -> DailyStat? {
        _ = try await todoRepository.deleteSingle(todo.id)
        let updatedStat = try await dailyStatRepository.getSingle(for: todo.deadline)
        
        WidgetManager.shared.updateWidget(.all)
        return updatedStat
    }
    
    func toggleTodo(_ todo: Todo) async throws -> DailyStat? {
        _ = try await todoRepository.toggleSingle(todo.id)
        let updatedStat = try await dailyStatRepository.getSingle(for: todo.deadline)
        
        return updatedStat
    }
}
