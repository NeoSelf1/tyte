/// 할 일 분류를 위한 태그 모델
///
/// 사용자가 Todo 항목을 분류하기 위해 사용하는 태그를 표현합니다.
/// - Properties:
///   - id: 태그 고유 식별자
///   - name: 태그 이름
///   - color: 태그 색상 (헥사코드)
///   - userId: 태그 소유자 식별자

import Foundation
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
