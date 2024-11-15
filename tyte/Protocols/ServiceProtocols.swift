import Combine
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) -> AnyPublisher<T, APIError>
    
    func requestWithoutAuth<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) -> AnyPublisher<T, APIError>
}

protocol AuthServiceProtocol {
    func socialLogin(idToken: String, provider: String) -> AnyPublisher<LoginResponse, APIError>
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError>
    func signUp(email: String, username: String, password: String) -> AnyPublisher<LoginResponse, APIError>
    func validateToken(_ token: String) -> AnyPublisher<ValidateResponse, APIError>
    func deleteAccount() -> AnyPublisher<EmptyResponse, APIError>
    func checkEmail(_ email: String) -> AnyPublisher<ValidateResponse, APIError>
}

protocol TodoServiceProtocol {
    func fetchTodos(for date: String) -> AnyPublisher<TodosResponse, APIError>
    func fetchTodos(for id: String, in deadline: String) -> AnyPublisher<TodosResponse, APIError>
    func createTodo(text: String) -> AnyPublisher<TodosResponse, APIError>
    func updateTodo(todo: Todo) -> AnyPublisher<TodoResponse, APIError>
    func deleteTodo(id: String) -> AnyPublisher<TodoResponse, APIError>
    func toggleTodo(id: String) -> AnyPublisher<TodoResponse, APIError>
}

protocol TagServiceProtocol {
    func fetchTags() -> AnyPublisher<TagsResponse, APIError>
    func createTag(name: String, color: String) -> AnyPublisher<TagIdResponse, APIError>
    func updateTag(_ tag: Tag) -> AnyPublisher<TagIdResponse, APIError>
    func deleteTag(id: String) -> AnyPublisher<TagIdResponse, APIError>
}

protocol DailyStatServiceProtocol {
    func fetchDailyStat(for date: String) -> AnyPublisher<DailyStatResponse, APIError>
    func fetchMonthlyStats(range: String) -> AnyPublisher<MonthlyStatsResponse, APIError>
    func fetchMonthlyStats(for id: String, in range: String) -> AnyPublisher<MonthlyStatsResponse, APIError>
}

protocol SocialServiceProtocol {
    func getFriends() -> AnyPublisher<[User], APIError>
    func searchUsers(query: String) -> AnyPublisher<[SearchResult], APIError>
    func requestFriend(userId: String) -> AnyPublisher<FriendRequestIdResponse, APIError>
    func getPendingRequests() -> AnyPublisher<[FriendRequest], APIError>
    func acceptFriendRequest(requestId: String) -> AnyPublisher<FriendRequestIdResponse, APIError>
    func rejectFriendRequest(requestId: String) -> AnyPublisher<EmptyResponse, APIError>
    func removeFriend(friendId: String) -> AnyPublisher<EmptyResponse, APIError>
}
