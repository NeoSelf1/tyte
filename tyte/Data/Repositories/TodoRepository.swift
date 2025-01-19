/// Todo 항목에 대한 데이터 접근을 관리하는 Repository입니다.
///
/// 다음과 같은 데이터 접근 기능을 제공합니다:
/// - Todo 로컬/리모트 CRUD 작업
/// - 오프라인 동기화 처리
/// - 날짜별 Todo 필터링
///
/// ## 사용 예시
/// ```swift
/// let todoRepository = TodoRepository()
///
/// // Todo 조회
/// let todos = try await todoRepository.get(in: "2024-01-20")
///
/// // 오프라인 상태에서 Todo 수정
/// try await todoRepository.updateSingle(modifiedTodo)
/// // -> SyncManager가 자동으로 동기화 작업 큐에 추가
/// ```
///
/// ## 관련 타입
/// - ``TodoRemoteDataSource``
/// - ``TodoLocalDataSource``
/// - ``SyncManager``
///
/// - Note: NetworkManager를 통해 네트워크 상태를 감지하고 적절한 데이터 소스를 선택합니다.
/// - SeeAlso: ``TagRepository``
class TodoRepository: TodoRepositoryProtocol {
    private let remoteDataSource: TodoRemoteDataSource
    private let localDataSource: TodoLocalDataSource
    private let syncManager: SyncManagerProtocol
    
    init(
        remoteDataSource: TodoRemoteDataSource = TodoRemoteDataSource(),
        localDataSource: TodoLocalDataSource = TodoLocalDataSource(),
        syncManager: SyncManagerProtocol = SyncManager.shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncManager = syncManager
    }
    
    func get(in date: String) async throws -> [Todo] {
        if NetworkManager.shared.isConnected {
            do {
                let remoteTodos = try await remoteDataSource.fetchTodos(in: date)
                try localDataSource.saveTodos(remoteTodos)
                return remoteTodos
            } catch {
                return try localDataSource.getTodos(for: date)
            }
        } else {
            return try localDataSource.getTodos(for: date)
        }
    }
    
    func get(in date: String, for id: String) async throws -> [Todo] {
        return try await remoteDataSource.fetchTodos(in: date, for: id)
    }
    
    func create(text: String, in date: String) async throws -> [Todo] {
        let todos = try await remoteDataSource.createTodo(text: text, in: date)
        try localDataSource.saveTodos(todos)
        
        return todos
    }
    
    func updateSingle(_ todo: Todo) async throws {
        if NetworkManager.shared.isConnected {
            _ = try await remoteDataSource.updateTodo(todo)
            try localDataSource.saveTodo(todo)
        } else {
            try localDataSource.saveTodo(todo)
            syncManager.enqueueOperation(.updateTodo(todo))
        }
    }
    
    func deleteSingle(_ id: String) async throws {
        if NetworkManager.shared.isConnected {
            _ = try await remoteDataSource.deleteTodo(id)
            try localDataSource.deleteTodo(id)
        } else {
            try localDataSource.deleteTodo(id)
            syncManager.enqueueOperation(.deleteTodo(id))
        }
    }
    
    func toggleSingle(_ id: String) async throws {
        let toggledTodo = try await remoteDataSource.toggleTodo(id)
        try localDataSource.saveTodo(toggledTodo)
    }
    
    /// ``TagUseCase``에서 Tag와 연결된 Todo배열 접근 위해 접근
    func getWithTag(id: String) async throws -> [Todo] {
        let allTodos = try localDataSource.getAllTodos()
        return allTodos.filter { $0.tag?.id == id }
    }
}
