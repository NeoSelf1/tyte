import Combine
/// 소셜 기능 관련 API 요청을 처리하는 프로토콜입니다.
/// 친구 관리 및 사용자 검색 기능을 담당합니다.

protocol SocialServiceProtocol {
    /// 친구 목록 조회
    func getFriends() -> AnyPublisher<[User], APIError>
    /// 사용자 검색
    func searchUsers(query: String) -> AnyPublisher<[SearchResult], APIError>
    /// 친구 요청 보내기
    func requestFriend(userId: String) -> AnyPublisher<IdResponse, APIError>
    /// 받은 친구 요청 목록 조회
    func getPendingRequests() -> AnyPublisher<[FriendRequest], APIError>
    /// 친구 요청 수락
    func acceptFriendRequest(requestId: String) -> AnyPublisher<IdResponse, APIError>
    /// 친구 요청 거절
    func rejectFriendRequest(requestId: String) -> AnyPublisher<EmptyResponse, APIError>
    /// 친구 삭제
    func removeFriend(friendId: String) -> AnyPublisher<EmptyResponse, APIError>
}
