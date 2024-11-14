//
//  ServiceProtocols.swift
//  tyte
//
//  Created by Neoself on 10/31/24.
//
import Combine
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) -> AnyPublisher<T, APIError>
    
    func requestWithoutAuth<T: Decodable>(_ endpoint: APIEndpoint,
                                          method: HTTPMethod,
                                          parameters: Parameters?) -> AnyPublisher<T, APIError>
}

protocol AuthServiceProtocol {
    func socialLogin(idToken: String, provider:String) -> AnyPublisher<LoginResponse, APIError>
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError>
    func signUp(email: String, username: String, password: String) -> AnyPublisher<LoginResponse, APIError>
    func validateToken(_ token: String) -> AnyPublisher<Bool, APIError>
    func deleteAccount() -> AnyPublisher<String, APIError>
    func checkEmail(_ email:String) -> AnyPublisher<Bool,APIError>
}

protocol TodoServiceProtocol {
    func fetchTodos(for date: String) -> AnyPublisher<[Todo], APIError>
    func fetchTodos(for id: String, in deadline:String) -> AnyPublisher<[Todo], APIError>
    func createTodo(text: String) -> AnyPublisher<[Todo], APIError>
    func updateTodo(todo: Todo) -> AnyPublisher<Todo, APIError>
    func deleteTodo(id: String) -> AnyPublisher<Todo, APIError>
    func toggleTodo(id: String) -> AnyPublisher<Todo, APIError>
}

protocol TagServiceProtocol {
    func fetchTags() -> AnyPublisher<[Tag], APIError>
    func createTag(name: String, color: String) -> AnyPublisher<String, APIError>
    func updateTag(_ tag: Tag) -> AnyPublisher<String, APIError>
    func deleteTag(id: String) -> AnyPublisher<String, APIError>
}

protocol DailyStatServiceProtocol {
    func fetchDailyStat(for date: String) -> AnyPublisher<DailyStat, APIError>
    func fetchMonthlyStats(range: String) -> AnyPublisher<[DailyStat], APIError>
    func fetchMonthlyStats(for id:String, in range:String) -> AnyPublisher<[DailyStat], APIError>
}

protocol SocialServiceProtocol {
    func getFriends() -> AnyPublisher<[User], APIError>
    func searchUsers(query: String) -> AnyPublisher<[SearchResult], APIError>
    func requestFriend(userId: String) -> AnyPublisher<String, APIError>
    func getPendingRequests() -> AnyPublisher<[FriendRequest], APIError>
    func acceptFriendRequest(requestId: String) -> AnyPublisher<String, APIError>
    func rejectFriendRequest(requestId: String) -> AnyPublisher<String, APIError>
    func removeFriend(friendId: String) -> AnyPublisher<String, APIError>
}
