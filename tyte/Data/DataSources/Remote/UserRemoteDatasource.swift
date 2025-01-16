/// 소셜 기능 관련 API 요청을 처리하는 프로토콜입니다.
/// 친구 관리 및 사용자 검색 기능을 담당합니다.
protocol UserRemoteDataSourceProtocol {
    /// 친구 목록 조회
    func getFriendUsers() async throws -> FriendsResponse
    /// 사용자 검색
    func searchUser(query: String) async throws -> SearchUsersResponse
    /// 친구 요청 보내기
    func postFriendRequest(userId: String) async throws -> IdResponse
    /// 받은 친구 요청 목록 조회
    func getPendingRequest() async throws -> FriendRequestsResponse
    /// 친구 요청 수락
    func acceptFriendRequest(requestId: String) async throws -> IdResponse
}

/// SocialService는 앱의 소셜 기능과 관련된 네트워크 요청을 처리하는 서비스입니다.
/// 친구 관리, 사용자 검색, 친구 요청 등의 기능을 제공합니다.
class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    /// 네트워크 요청을 처리하는 서비스
    private let networkService: NetworkServiceProtocol
        
    /// SocialService 초기화
    /// - Parameter networkService: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// 현재 사용자의 친구 목록을 조회합니다.
    /// - Returns: 친구 목록 정보를 포함한 Publisher
    func getFriendUsers() async throws -> FriendsResponse {
        return try await networkService.request(.getFriends, method: .get, parameters: nil)
    }
    
    /// 친구요청을 하기 위한 사용자를 검색합니다.
    /// - Parameter query: 검색할 사용자의 이름 또는 이메일
    /// - Returns: 검색된 사용자 목록을 포함한 Publisher
    func searchUser(query: String) async throws -> SearchUsersResponse {
        return try await networkService.request(.searchUser(query), method: .get, parameters: nil)
    }
    
    /// 특정 사용자에게 친구 요청을 보냅니다.
    /// - Parameter userId: 친구 요청을 보낼 사용자의 ID
    /// - Returns: 생성된 친구 요청의 ID를 포함한 Publisher
    func postFriendRequest(userId: String) async throws -> IdResponse {
        return try await networkService.request(.requestFriend(userId), method: .post, parameters: nil)
    }
    
    /// 현재 사용자가 받은 친구 요청 목록을 조회합니다.
    /// - Returns: 대기 중인 친구 요청 목록을 포함한 Publisher
    func getPendingRequest() async throws -> FriendRequestsResponse {
        return try await networkService.request(.getPendingRequests, method: .get, parameters: nil)
    }
    
    /// 받은 친구 요청을 수락합니다.
    /// - Parameter requestId: 수락할 친구 요청의 ID
    /// - Returns: 수락된 친구 요청의 ID를 포함한 Publisher
    func acceptFriendRequest(requestId: String) async throws -> IdResponse {
        return try await networkService.request(.acceptFriendRequest(requestId), method: .patch, parameters: nil)
    }
}
