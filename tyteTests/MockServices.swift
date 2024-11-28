//
//  MockServices.swift
//  tyte
//
//  Created by Neoself on 11/21/24.
//
import Combine
import Foundation
@testable import tyte


class MockAppState {
    var isLoggedIn: Bool = true
}

// MARK: - Mock Services
class MockTodoService: TodoServiceProtocol {
   func fetchTodos(for date: String) -> AnyPublisher<TodosResponse, APIError> {
       let todos = [Todo(
           id: "mock-id",
           raw: "Mock todo",
           title: "Mock todo",
           isImportant: false,
           isLife: true,
           tagId: nil,
           difficulty: 3,
           estimatedTime: 30,
           deadline: date,
           isCompleted: false,
           user: "test-user"
       )]
       return Just(todos)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func createTodo(text: String) -> AnyPublisher<TodosResponse, APIError> {
       let todo = Todo(
           id: "new-id",
           raw: text,
           title: text,
           isImportant: false,
           isLife: true,
           tagId: nil,
           difficulty: 3,
           estimatedTime: 30,
           deadline: Date().apiFormat,
           isCompleted: false,
           user: "test-user"
       )
       return Just([todo])
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func updateTodo(todo: Todo) -> AnyPublisher<TodoResponse, APIError> {
       return Just(todo)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func deleteTodo(id: String) -> AnyPublisher<TodoResponse, APIError> {
       let todo = Todo(
           id: id,
           raw: "Deleted todo",
           title: "Deleted todo",
           isImportant: false,
           isLife: true,
           tagId: nil,
           difficulty: 3,
           estimatedTime: 30,
           deadline: Date().apiFormat,
           isCompleted: false,
           user: "test-user"
       )
       return Just(todo)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func toggleTodo(id: String) -> AnyPublisher<TodoResponse, APIError> {
       let todo = Todo(
           id: id,
           raw: "Toggled todo",
           title: "Toggled todo",
           isImportant: false,
           isLife: true,
           tagId: nil,
           difficulty: 3,
           estimatedTime: 30,
           deadline: Date().apiFormat,
           isCompleted: true,
           user: "test-user"
       )
       return Just(todo)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func fetchTodos(for id: String, in deadline: String) -> AnyPublisher<TodosResponse, APIError> {
       return Just([])
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
}

class MockDailyStatService: DailyStatServiceProtocol {
   func fetchDailyStat(for date: String) -> AnyPublisher<DailyStat?, APIError> {
       let dailyStat = DailyStat(
           date: date,
           user: "mock-user",
           balanceData: BalanceData(
               title: "Mock",
               message: "Mock message",
               balanceNum: 50
           ),
           productivityNum: 75.0,
           tagStats: [],
           center: SIMD2<Float>(x: 0.5, y: 0.5)
       )
       return Just(dailyStat)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func fetchMonthlyStats(in yearMonth: String) -> AnyPublisher<MonthlyStatsResponse, APIError> {
       let dailyStats = [DailyStat(
           date: Date().apiFormat,
           user: "mock-user",
           balanceData: BalanceData(
               title: "Mock",
               message: "Mock message",
               balanceNum: 50
           ),
           productivityNum: 75.0,
           tagStats: [],
           center: SIMD2<Float>(x: 0.5, y: 0.5)
       )]
       return Just(dailyStats)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func fetchMonthlyStats(for id: String, in yearMonth: String) -> AnyPublisher<MonthlyStatsResponse, APIError> {
       return Just([])
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
}

class MockTagService: TagServiceProtocol {
   func fetchTags() -> AnyPublisher<TagsResponse, APIError> {
       let tags = [Tag(
           id: "mock-tag",
           name: "Mock Tag",
           color: "FF0000",
           user: "mock-user"
       )]
       return Just(tags)
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func createTag(name: String, color: String) -> AnyPublisher<IdResponse, APIError> {
       return Just(IdResponse(id: "new-tag-id"))
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func updateTag(_ tag: Tag) -> AnyPublisher<IdResponse, APIError> {
       return Just(IdResponse(id: tag.id))
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
   
   func deleteTag(id: String) -> AnyPublisher<IdResponse, APIError> {
       return Just(IdResponse(id: id))
           .delay(for: .milliseconds(100), scheduler: RunLoop.main)
           .setFailureType(to: APIError.self)
           .eraseToAnyPublisher()
   }
}

class MockAuthService: AuthServiceProtocol {
    var mockLoginResult: Result<LoginResponse, APIError>?
    var mockSignUpResult: Result<LoginResponse, APIError>?
    var mockCheckEmailResult: Result<ValidateResponse, APIError>?
    
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        return Future<LoginResponse, APIError> { promise in
            if let result = self.mockLoginResult {
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, username: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        return Future<LoginResponse, APIError> { promise in
            if let result = self.mockSignUpResult {
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func checkEmail(_ email: String) -> AnyPublisher<ValidateResponse, APIError> {
        return Future<ValidateResponse, APIError> { promise in
            if let result = self.mockCheckEmailResult {
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func validateToken(_ token: String) -> AnyPublisher<ValidateResponse, APIError> {
        return Empty().eraseToAnyPublisher()
    }
    
    func socialLogin(idToken: String, provider: String) -> AnyPublisher<LoginResponse, APIError> {
        return Empty().eraseToAnyPublisher()
    }
    
    func deleteAccount() -> AnyPublisher<EmptyResponse, APIError> {
        return Empty().eraseToAnyPublisher()
    }
}
