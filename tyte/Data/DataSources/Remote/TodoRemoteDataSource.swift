protocol TodoRemoteDataSourceProtocol {
    func fetchTodos(in date: String) async throws -> TodosResponse
    func fetchTodos(in date: String, for id: String) async throws -> TodosResponse
    func createTodo(text: String, in date: String) async throws -> TodosResponse
    func updateTodo(_ todo: Todo) async throws -> TodoResponse
    func deleteTodo(_ id: String) async throws -> TodoResponse
    func toggleTodo(_ id: String) async throws -> TodoResponse
}

/// Todo 항목에 대한 원격 데이터 접근을 담당하는 DataSource입니다.
///
/// 서버와의 통신을 통해 다음 기능을 제공합니다:
/// - Todo CRUD 작업 처리
/// - 날짜별 Todo 조회
/// - 특정 사용자의 Todo 조회
///
/// ## 사용 예시
/// ```swift
/// let todoDataSource = TodoRemoteDataSource()
///
/// // 특정 날짜의 Todo 조회
/// let todos = try await todoDataSource.fetchTodos(in: "2024-01-20")
///
/// // 새 Todo 생성
/// let newTodos = try await todoDataSource.createTodo(
///     text: "회의 준비하기",
///     in: "2024-01-20"
/// )
/// ```
///
/// ## API Endpoints
/// - GET /todo/{date}: 날짜별 Todo 조회
/// - POST /todo: Todo 생성
/// - PUT /todo/{id}: Todo 수정
/// - DELETE /todo/{id}: Todo 삭제
///
/// ## 관련 타입
/// - ``NetworkAPI``
/// - ``APIEndpoint``
/// - ``Todo``
///
/// - Note: 모든 요청은 인증이 필요합니다.
/// - SeeAlso: ``TodoRepository``, ``APIEndpoint``
class TodoRemoteDataSource: TodoRemoteDataSourceProtocol {
    private let networkAPI: NetworkAPI
    
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    func fetchTodos(in date: String) async throws ->TodosResponse {
        return try await networkAPI.request(.fetchTodosForDate(date), method: .get, parameters: nil)
    }
    
    func fetchTodos(in date: String, for id: String) async throws -> TodosResponse {
        return try await networkAPI.request(.fetchFriendTodosForDate(friendId: id, deadline: date), method: .get, parameters: nil)
    }
    
    func createTodo(text: String, in date: String) async throws -> TodosResponse {
        return try await networkAPI.request(
            .createTodo,
            method: .post,
            parameters: ["text": text, "selectedDate": date]
        )
    }
    
    func updateTodo(_ todo: Todo) async throws -> TodoResponse {
        return try await networkAPI.request(
            .updateTodo(todo.id),
            method: .put,
            parameters: todo.dictionary
        )
    }
    
    func deleteTodo(_ id: String) async throws -> TodoResponse {
        return try await networkAPI.request(.deleteTodo(id), method: .delete, parameters: nil)
    }
    
    func toggleTodo(_ id: String) async throws -> TodoResponse {
        return try await networkAPI.request(.toggleTodo(id), method: .patch, parameters: nil)
    }
}
