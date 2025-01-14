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
import Foundation

protocol TodoUseCaseProtocol {
    func getTodayTodos() async throws -> [Todo]
    func getTodosByDateRange(start: String, end: String) async throws -> [Todo]
    func createTodo(text: String, deadline: String) async throws -> [Todo]
    func updateTodo(_ todo: Todo) async throws -> Todo
    func deleteTodo(_ id: String) async throws
    func toggleTodo(_ id: String) async throws -> Todo
}

class TodoUseCase: TodoUseCaseProtocol {
    private let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func getTodayTodos() async throws -> [Todo] {
        let today = Date().apiFormat
        return try await repository.get(for: today)
    }
    
    func getTodosByDateRange(start: String, end: String) async throws -> [Todo] {
        var allTodos: [Todo] = []
        var currentDate = start.parsedDate
        let endDate = end.parsedDate
        
        while currentDate <= endDate {
            let todos = try await repository.get(for: currentDate.apiFormat)
            allTodos.append(contentsOf: todos)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return allTodos
    }
    
    func createTodo(text: String, deadline: String) async throws -> [Todo] {
        return try await repository.create(text: text, in: deadline)
    }
    
    func updateTodo(_ todo: Todo) async throws -> Todo {
        return try await repository.updateSingle(todo)
    }
    
    func deleteTodo(_ id: String) async throws {
        _ = try await repository.deleteSingle(id)
    }
    
    func toggleTodo(_ id: String) async throws -> Todo {
        return try await repository.toggleSingle(id)
    }
}
