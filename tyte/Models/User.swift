/// 사용자 정보를 나타내는 기본 모델
///
/// 앱 내의 사용자 정보를 표현하는 기본 데이터 구조입니다.
/// - Properties:
///   - id: 사용자 고유 식별자
///   - username: 사용자 이름
///   - email: 사용자 이메일 주소
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email
    }
}

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
