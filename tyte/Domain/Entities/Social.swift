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

/// 사용자 검색 결과를 나타내는 모델
///
/// 친구 검색 및 사용자 검색 기능에서 반환되는 결과를 표현합니다.
/// - Properties:
///   - id: 사용자 고유 식별자
///   - username: 사용자 이름
///   - email: 사용자 이메일
///   - isFriend: 현재 사용자와 친구 관계 여부
///   - isPending: 친구 요청 대기 상태 여부
struct SearchResult: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let isFriend: Bool
    var isPending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email, isFriend, isPending
    }
}
