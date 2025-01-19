/// 사용자 정보를 나타내는 기본 데이터 모델입니다.
///
/// 다음과 같은 사용자 정보를 포함합니다:
/// - 기본 식별 정보 (ID, 이메일)
/// - 표시 정보 (사용자명)
///
/// ## 사용 예시
/// ```swift
/// // 사용자 생성
/// let user = User(
///     id: "user-1",
///     username: "John Doe",
///     email: "john@example.com"
/// )
///
/// // 친구 요청에서 사용
/// let request = FriendRequest(
///     id: "request-1",
///     fromUser: user,
///     status: "pending"
/// )
/// ```
///
/// ## 관련 타입
/// - ``FriendRequest``
/// - ``SearchResult``
/// - ``UserRepository``
///
/// - Note: MongoDB의 _id 필드를 id로 매핑합니다.
/// - SeeAlso: ``UserUseCase``, 사용자 관련 비즈니스 로직 처리에 사용
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email
    }
}

