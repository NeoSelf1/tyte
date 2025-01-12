/// 친구 요청 정보를 나타내는 모델
///
/// 사용자 간의 친구 요청 상태와 정보를 표현합니다.
/// - Properties:
///   - id: 친구 요청 고유 식별자
///   - fromUser: 요청을 보낸 사용자 정보
///   - status: 현재 요청 상태
struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUser: User
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fromUser
        case status
    }
}
