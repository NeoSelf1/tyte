import Foundation

/// Todo 분류를 위한 태그를 나타내는 데이터 모델입니다.
///
/// 다음과 같은 태그 정보를 포함합니다:
/// - 기본 정보 (이름, 색상)
/// - 소유자 정보
///
/// ## 사용 예시
/// ```swift
/// // 태그 생성
/// let tag = Tag(
///     id: "tag-1",
///     name: "업무",
///     color: "FF0000",
///     userId: "user-1"
/// )
///
/// // Todo에 태그 적용
/// todo.tag = tag
/// ```
///
/// ## 관련 타입
/// - ``Todo``
/// - ``TagStat``
/// - ``TagEntity``
///
/// - Note: color는 HEX 형식의 문자열입니다.
/// - SeeAlso: ``TagRepository``, 태그 CRUD 작업 처리에 사용
struct Tag: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    let color: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case userId = "user"
        case name, color
    }
}
