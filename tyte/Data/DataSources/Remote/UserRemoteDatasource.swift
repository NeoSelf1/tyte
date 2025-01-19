protocol UserRemoteDataSourceProtocol {
    func getFriendUsers() async throws -> FriendsResponse
    func searchUser(query: String) async throws -> SearchUsersResponse
    func postFriendRequest(userId: String) async throws -> IdResponse
    func getPendingRequest() async throws -> FriendRequestsResponse
    func acceptFriendRequest(requestId: String) async throws -> IdResponse
}

/// 사용자 간 소셜 기능에 대한 원격 데이터 접근을 담당하는 DataSource입니다.
///
/// 서버와의 통신을 통해 다음 소셜 기능을 제공합니다:
/// - 친구 검색 및 추가
/// - 친구 요청 관리
/// - 친구 목록 조회
///
/// ## 사용 예시
/// ```swift
/// let userDataSource = UserRemoteDataSource()
///
/// // 사용자 검색
/// let searchResults = try await userDataSource.searchUser(
///     query: "john"
/// )
///
/// // 친구 요청 보내기
/// let requestId = try await userDataSource.postFriendRequest(
///     userId: "user-123"
/// )
/// ```
///
/// ## API Endpoints
/// - GET /social: 친구 목록 조회
/// - GET /social/search/{query}: 사용자 검색
/// - POST /social/request/{userId}: 친구 요청
/// - GET /social/requests/pending: 받은 요청 목록
/// - PATCH /social/accept/{requestId}: 요청 수락
///
/// ## 관련 타입
/// - ``NetworkAPI``
/// - ``FriendsResponse``
/// - ``SearchUsersResponse``
/// - ``IdResponse``
///
/// - Note: 모든 요청에 인증이 필요합니다.
/// - SeeAlso: ``UserRepository``, ``APIEndpoint``
class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let networkAPI: NetworkAPI
    
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    func getFriendUsers() async throws -> FriendsResponse {
        return try await networkAPI.request(.getFriends, method: .get, parameters: nil)
    }
    
    func searchUser(query: String) async throws -> SearchUsersResponse {
        return try await networkAPI.request(.searchUser(query), method: .get, parameters: nil)
    }
    
    func postFriendRequest(userId: String) async throws -> IdResponse {
        return try await networkAPI.request(.requestFriend(userId), method: .post, parameters: nil)
    }
    
    func getPendingRequest() async throws -> FriendRequestsResponse {
        return try await networkAPI.request(.getPendingRequests, method: .get, parameters: nil)
    }
    
    func acceptFriendRequest(requestId: String) async throws -> IdResponse {
        return try await networkAPI.request(.acceptFriendRequest(requestId), method: .patch, parameters: nil)
    }
}
