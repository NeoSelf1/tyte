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
    case checkEmail
    case validateToken // Token
    case socialLogin(String) // Provider
    case deleteAccount
    case fetchTodosForDate(String) // deadline
    case fetchFriendTodosForDate(friendId:String, deadline:String)
    case createTodo
    case toggleTodo(String) // todoId
    case updateTodo(String)  // todoId
    case deleteTodo(String)  // todoId
    case fetchTags
    case createTag
    case updateTag(String)  // tagId
    case deleteTag(String)  // tagId
    case fetchDailyStatsForDate(String) // date
    case fetchDailyStatsForMonth(String) // range
    case searchUser(String) // query
    case requestFriend(String) // userId
    case getFriends
    
    case getPendingRequests // 받은 친구 요청 목록 조회
    case acceptFriendRequest(String) // requestId
    case rejectFriendRequest(String) // requestId
    case getFriendDailyStats(friendId: String, range: String) // 친구의 DailyStat 조회
    case removeFriend(String) // friendId
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        case .deleteAccount:
            return "/auth"
        case .validateToken:
            return "/auth/validate-token"
        case .checkEmail:
            return "/auth/check"
        case .socialLogin(let provider):
            return "/auth/\(provider)"
            
        case .fetchTodosForDate(let deadline):
            return "/todo/\(deadline)"
        case .fetchFriendTodosForDate(let friendId, let deadline):
            return "/todo/friend/\(friendId)/\(deadline)"
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
            
        case .fetchDailyStatsForDate(let date):
            return "/dailyStat/\(date)"
        case .fetchDailyStatsForMonth(let range):
            return "/dailyStat/all/\(range)"
        case .getFriendDailyStats(let friendId, let range):
            return "/dailyStat/friend/\(friendId)/\(range)"
            
        case .searchUser(let query):
            return "/social/search/\(query)"
        case .getFriends:
            return "/social"
        case .requestFriend(let userId):
            return "/social/request/\(userId)"
        case .getPendingRequests:
            return "/social/requests/pending"
            
        case .acceptFriendRequest(let requestId):
            return "/social/accept/\(requestId)"
        case .rejectFriendRequest(let requestId):
            return "/social/reject/\(requestId)"
        case .removeFriend(let friendId):
            return "/social/\(friendId)"
        }
    }
}
