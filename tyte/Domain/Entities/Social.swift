/// 소셜 기능 관련 데이터 모델들을 정의합니다.
///
/// ## 친구 요청 모델
/// ```swift
/// /// 친구 요청의 상태와 관련 정보를 관리합니다.
/// struct FriendRequest {
///     let id: String          // 요청 식별자
///     let fromUser: User      // 요청자 정보
///     let status: String      // 요청 상태
/// }
/// ```
///
/// ## 검색 결과 모델
/// ```swift
/// /// 사용자 검색 결과를 표현합니다.
/// struct SearchResult {
///     let id: String          // 사용자 식별자
///     let username: String    // 사용자명
///     let email: String       // 이메일
///     let isFriend: Bool      // 친구 여부
///     var isPending: Bool     // 요청 대기 상태
/// }
/// ```
///
/// ## 관련 타입
/// - ``User``
/// - ``UserUseCase``
/// - ``UserRepository``
///
/// - Note: 친구 관계 상태는 isFriend와 isPending으로 구분됩니다.
/// - SeeAlso: ``SocialView``, 소셜 기능 UI 구현에 사용
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
