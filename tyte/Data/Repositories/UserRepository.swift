/// 사용자 간 소셜 기능 관련 데이터 접근을 관리하는 Repository입니다.
///
/// 다음과 같은 데이터 접근 기능을 제공합니다:
/// - 친구 검색 및 요청 처리
/// - 친구 목록 관리
/// - 친구 요청 상태 관리
///
/// ## 사용 예시
/// ```swift
/// let userRepository = UserRepository()
///
/// // 친구 검색
/// let results = try await userRepository.search(query: "john")
///
/// // 친구 요청 보내기
/// try await userRepository.postFriendRequest("user-123")
/// ```
///
/// ## 관련 타입
/// - ``UserRemoteDataSource``
/// - ``NetworkManager``
/// - ``APIError``
///
/// - Note: 소셜 기능은 네트워크 연결이 필수적입니다.
/// - Important: 네트워크 에러 발생 시 적절한 피드백이 필요합니다.
class UserRepository: UserRepositoryProtocol {
    
    private let remoteDataSource: UserRemoteDataSourceProtocol
    
    init(
        remoteDataSource: UserRemoteDataSourceProtocol = UserRemoteDataSource()
    ) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getFriends(for date: String) async throws -> [User] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.getFriendUsers()
    }
    
    
    func search(query: String) async throws -> [SearchResult] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.searchUser(query: query)
    }
    
    func postFriendRequest(_ userId: String) async throws {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        _ = try await remoteDataSource.postFriendRequest(userId: userId)
    }
    
    func getPendingRequest() async throws -> [FriendRequest] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.getPendingRequest()
    }
    
    func acceptFriendRequest(_ id: String) async throws {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        _ = try await remoteDataSource.acceptFriendRequest(requestId: id)
    }
}
