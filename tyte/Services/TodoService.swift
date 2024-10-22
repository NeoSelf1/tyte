//
//  TodoService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//
import Foundation
import Combine

class TodoService {
    static let shared = TodoService()
    
    private let apiManager = APIManager.shared
    
    func fetchAllTodos(mode:String) -> AnyPublisher<[Todo], APIError> {
        let endpoint = APIEndpoint.fetchTodos(mode)
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[Todo], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchTodosForDate(deadline: String) -> AnyPublisher<[Todo], APIError> {
        let endpoint = APIEndpoint.fetchTodosForDate(deadline)
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[Todo], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func createTodo(text: String) -> AnyPublisher<[Todo], APIError> {
        let endpoint = APIEndpoint.createTodo
        let parameters: [String: Any] = [
            "text": text
        ]
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .post, parameters: parameters) { (result: Result<[Todo], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func toggleTodo(id: String) -> AnyPublisher<Todo, APIError> {
        let endpoint = APIEndpoint.toggleTodo(id)
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .patch) { (result: Result<Todo, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func updateTodo(todo: Todo) -> AnyPublisher<Todo, APIError> {
        let endpoint = APIEndpoint.updateTodo(todo.id)
        let parameters = todo.dictionary
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .put, parameters: parameters) { (result: Result<Todo, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteTodo(id: String) -> AnyPublisher<Todo, APIError> {
        let endpoint = APIEndpoint.deleteTodo(id)
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .delete) { (result: Result<Todo, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
