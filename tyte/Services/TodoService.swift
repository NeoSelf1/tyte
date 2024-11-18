//
//  TodoService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//
import Foundation
import Combine

class TodoService: TodoServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchTodos(for date: String) -> AnyPublisher<[Todo], APIError> {
        return networkService.request(.fetchTodosForDate(date), method: .get, parameters: nil)
    }
    
    func fetchTodos(for id: String, in deadline: String) -> AnyPublisher<[Todo], APIError> {
        return networkService.request(.fetchFriendTodosForDate(friendId: id, deadline: deadline), method: .get, parameters: nil)
    }
    
    func createTodo(text: String) -> AnyPublisher<[Todo], APIError> {
        return networkService.request( .createTodo, method: .post, parameters: ["text": text])
    }
    
    func updateTodo(todo: Todo) -> AnyPublisher<Todo, APIError> {
        return networkService.request(.updateTodo(todo.id),method: .put,parameters: todo.dictionary)
    }
    
    func deleteTodo(id: String) -> AnyPublisher<Todo, APIError> {
        return networkService.request(.deleteTodo(id), method: .delete, parameters: nil)
    }
    
    func toggleTodo(id: String) -> AnyPublisher<Todo, APIError> {
        return networkService.request( .toggleTodo(id), method: .patch, parameters: nil)
    }
}

