protocol TodoServiceProtocol {
    /// 특정 날짜의 Todo 목록 조회
    func fetchTodos(for date: String) async throws -> TodosResponse
    /// 특정 사용자의 특정 날짜 Todo 목록 조회
    func fetchTodos(for id: String, in deadline: String) async throws -> TodosResponse
    /// 새로운 Todo 생성
    func createTodo(text: String, in date: String) async throws -> TodosResponse
    /// Todo 업데이트
    func updateTodo(todo: Todo) async throws -> TodoResponse
    /// Todo 삭제
    func deleteTodo(id: String) async throws -> TodoResponse
    /// Todo 완료 상태 토글
    func toggleTodo(id: String) async throws -> TodoResponse
}

/// TodoService는 할 일(Todo) 관련 네트워크 요청을 처리하는 서비스입니다.
/// Todo 항목의 CRUD 작업을 담당합니다.
/// 할 일의 생성, 조회, 수정, 삭제 및 완료 상태 토글 기능을 제공합니다.
class TodoService: TodoServiceProtocol {
    /// 네트워크 요청을 처리하는 서비스
    private let networkService: NetworkServiceProtocol
    
    /// TodoService 초기화
    /// - Parameter networkService: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// 특정 날짜의 할 일 목록을 조회합니다.
    /// - Parameter date: 조회할 날짜 (형식: "YYYY-MM-DD")
    /// - Returns: 해당 날짜의 할 일 목록을 포함한 Publisher
    func fetchTodos(for date: String) async throws -> [Todo] {
        return try await networkService.request(.fetchTodosForDate(date), method: .get, parameters: nil)
    }
    
    /// 특정 친구의 특정 날짜 할 일 목록을 조회합니다.
    /// - Parameters:
    ///   - id: 조회할 친구의 ID
    ///   - deadline: 조회할 날짜 (형식: "YYYY-MM-DD")
    /// - Returns: 해당 친구의 해당 날짜 할 일 목록을 포함한 Publisher
    func fetchTodos(for id: String, in deadline: String) async throws -> [Todo] {
        return try await networkService.request(.fetchFriendTodosForDate(friendId: id, deadline: deadline), method: .get, parameters: nil)
    }
    
    /// 새로운 할 일을 생성합니다.
    /// - Parameters:
    ///   - text: 할 일의 내용
    ///   - date: 할 일의 마감 날짜 (형식: "YYYY-MM-DD")
    /// - Returns: 생성된 할 일이 포함된 전체 할 일 목록을 포함한 Publisher
    func createTodo(text: String, in date: String) async throws -> [Todo] {
        return try await networkService.request(
            .createTodo,
            method: .post,
            parameters: ["text": text, "selectedDate": date]
        )
    }
    
    /// 기존 할 일을 수정합니다.
    /// - Parameter todo: 수정할 내용이 반영된 Todo 객체
    /// - Returns: 수정된 할 일 정보를 포함한 Publisher
    /// - Note: todo.dictionary를 통해 Todo 객체의 모든 필드가 서버로 전송됩니다.
    func updateTodo(todo: Todo) async throws -> Todo {
        return try await networkService.request(
            .updateTodo(todo.id),
            method: .put,
            parameters: todo.dictionary
        )
    }
    
    /// 할 일을 삭제합니다.
    /// - Parameter id: 삭제할 할 일의 ID
    /// - Returns: 삭제된 할 일 정보를 포함한 Publisher
    func deleteTodo(id: String) async throws -> Todo {
        return try await networkService.request(.deleteTodo(id), method: .delete, parameters: nil)
    }
    
    /// 할 일의 완료 상태를 토글합니다.
    /// - Parameter id: 상태를 토글할 할 일의 ID
    /// - Returns: 상태가 변경된 할 일 정보를 포함한 Publisher
    /// - Note: 완료 상태가 true면 false로, false면 true로 변경됩니다.
    func toggleTodo(id: String) async throws -> Todo {
        return try await networkService.request(.toggleTodo(id), method: .patch, parameters: nil)
    }
}
