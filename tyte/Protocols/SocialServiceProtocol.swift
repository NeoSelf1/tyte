/// 소셜 기능 관련 API 요청을 처리하는 프로토콜입니다.
/// 친구 관리 및 사용자 검색 기능을 담당합니다.
protocol SocialServiceProtocol {
    /// 친구 목록 조회
    func getFriends() async throws -> FriendsResponse
    /// 사용자 검색
    func searchUsers(query: String) async throws -> SearchUsersResponse
    /// 친구 요청 보내기
    func requestFriend(userId: String) async throws -> IdResponse
    /// 받은 친구 요청 목록 조회
    func getPendingRequests() async throws -> FriendRequestsResponse
    /// 친구 요청 수락
    func acceptFriendRequest(requestId: String) async throws -> IdResponse
    /// 친구 삭제
    func removeFriend(friendId: String) async throws -> EmptyResponse
}
