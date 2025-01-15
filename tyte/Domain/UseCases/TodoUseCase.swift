/// 앱의 비즈니스 로직 구현
/// 실제 사용자 시나리오에 맞는 작업 수행
/// 여러 Repository를 조합하여 복잡한 작업 수행
/// 도메인 규칙 검증
///
/// 핵심 차이점:
/// 추상화 수준
/// - Repository: 데이터 저장소 추상화 (How)
/// - UseCase: 비즈니스 요구사항 구현 (What)
///
/// 책임 범위
/// - Repository: 단일 데이터 타입에 대한 CRUD
/// - UseCase: 여러 데이터 타입과 규칙을 조합한 복잡한 작업
///
/// 의존성
/// - Repository: 인프라스트럭처 계층에 의존
/// - UseCase: Repository들에 의존
///
/// 재사용성
/// - Repository: 다양한 UseCase에서 재사용
/// - UseCase: 특정 비즈니스 시나리오에 특화
protocol TodoUseCaseProtocol {
    func getTodos(for dateString: String) async throws -> [Todo]
    func createTodo(text: String, deadline: String) async throws -> ([Todo], DailyStat?)
    func updateTodoWithStats(_ todo: Todo, from originalDate: String) async throws -> ([DailyStat])
    func toggleTodo(_ todo: Todo) async throws -> DailyStat?
    func deleteTodo(_ todo: Todo) async throws -> DailyStat?
}

class TodoUseCase: TodoUseCaseProtocol {
    private let todoRepository: TodoRepository
    private let dailyStatRepository: DailyStatRepository
        
    init(
        todoRepository: TodoRepository,
        dailyStatRepository: DailyStatRepository
    ) {
        self.todoRepository = todoRepository
        self.dailyStatRepository = dailyStatRepository
    }
    
    func getTodos(for dateString: String) async throws -> [Todo] {
        return try await todoRepository.get(for: dateString)
    }
    
    /// 비즈니스 로직의 캡슐화
    /// - Todo 수정이 DailyStat 갱신을 트리거하는 것은 앱의 핵심 비즈니스 규칙입니다
    /// - 이는 UI 레이어(ViewModel)가 아닌 도메인 레이어(UseCase)에서 관리되어야 합니다
    /// - 여러 ViewModel에서 Todo 수정이 필요할 경우 로직 중복을 방지할 수 있습니다
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
