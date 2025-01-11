import Combine
/// Todo 관련 API 요청을 처리하는 프로토콜입니다.
/// Todo 항목의 CRUD 작업을 담당합니다.

protocol TodoServiceProtocol {
    /// 특정 날짜의 Todo 목록 조회
    func fetchTodos(for date: String) -> AnyPublisher<TodosResponse, APIError>
    /// 특정 사용자의 특정 날짜 Todo 목록 조회
    func fetchTodos(for id: String, in deadline: String) -> AnyPublisher<TodosResponse, APIError>
    /// 새로운 Todo 생성
    func createTodo(text: String, in date: String) -> AnyPublisher<TodosResponse, APIError>
    /// Todo 업데이트
    func updateTodo(todo: Todo) -> AnyPublisher<TodoResponse, APIError>
    /// Todo 삭제
    func deleteTodo(id: String) -> AnyPublisher<TodoResponse, APIError>
    /// Todo 완료 상태 토글
    func toggleTodo(id: String) -> AnyPublisher<TodoResponse, APIError>
}
