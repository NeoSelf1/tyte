import Foundation

protocol UserUseCaseProtocol {
    func getFriends() async throws -> [User]
    func searchUsers(query: String) async throws -> [SearchResult]
    func requestFriend(userId: String) async throws
    func getPendingRequests() async throws -> [FriendRequest]
    func acceptFriendRequest(_ requestId: String) async throws
}

/// 사용자 간 소셜 기능을 처리하는 Use Case입니다.
///
/// 다음과 같은 소셜 기능을 제공합니다:
/// - 친구 검색 및 친구 요청
/// - 친구 요청 수락/거절
/// - 친구 목록 조회
/// - 친구의 통계/Todo 데이터 조회
///
/// ## 사용 예시
/// ```swift
/// let userUseCase = UserUseCase()
///
/// // 친구 검색
/// let results = try await userUseCase.searchUsers(query: "john")
///
/// // 친구 요청
/// try await userUseCase.requestFriend(userId: "user-123")
/// ```
///
/// ## 관련 타입
/// - ``UserRepository``
/// - ``User``
/// - ``SearchResult``
/// - ``FriendRequest``
///
/// - Note: 네트워크 연결이 필요한 기능들입니다.
/// - Note: Date 객체 사용을 위해 Foundation을 import해야 합니다.
/// - SeeAlso: ``DailyStatUseCase``, 친구의 통계 데이터 조회에 사용됩니다.
class UserUseCase: UserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.userRepository = userRepository
    }
    
    func getFriends() async throws -> [User] {
        return try await userRepository.getFriends(for: Date().apiFormat)
    }
    
    func searchUsers(query: String) async throws -> [SearchResult] {
        return try await userRepository.search(query: query)
    }
    
    func requestFriend(userId: String) async throws {
        try await userRepository.postFriendRequest(userId)
    }
    
    func getPendingRequests() async throws -> [FriendRequest] {
        return try await userRepository.getPendingRequest()
    }
    
    func acceptFriendRequest(_ requestId: String) async throws {
        try await userRepository.acceptFriendRequest(requestId)
    }
}
