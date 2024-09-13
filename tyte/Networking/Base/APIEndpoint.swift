//
//  APIEndpoint.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation

enum APIEndpoint {
    case login
    case signUp
    case fetchTodos(String) // mode
    case fetchTodosForDate(String) // deadline
    case createTodo
    case toggleTodo(String) // todoId
    case updateTodo(String)  // todoId
    case deleteTodo(String)  // todoId
    case fetchTags
    case createTag
    case updateTag(String)  // tagId
    case deleteTag(String)  // tagId
    case fetchDailyStats
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        case .fetchTodos(let mode):
            return "/todo/all/\(mode)"
        case .fetchTodosForDate(let deadline):
            return "/todo/\(deadline)"
        case .createTodo:
            return "/todo"
        case .toggleTodo(let todoId):
            return "/todo/toggle/\(todoId)"
        case .updateTodo(let todoId):
            return "/todo/\(todoId)"
        case .deleteTodo(let todoId):
            return "/todo/\(todoId)"
        case .fetchTags:
            return "/tag"
        case .createTag:
            return "/tag"
        case .updateTag(let tagId):
            return "/tag/\(tagId)"
        case .deleteTag(let tagId):
            return "/tag/\(tagId)"
        case .fetchDailyStats:
            return "/dailyStat"
        }
    }
}
