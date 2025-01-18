import Foundation
/// Todo 항목을 나타내는 모델
///
/// 사용자의 할 일 항목을 표현하며, 작업의 상세 정보를 포함합니다.
/// - Properties:
///   - id: Todo 항목 고유 식별자
///   - raw: 원본 입력 텍스트
///   - title: 할 일 제목
///   - isImportant: 중요 여부
///   - isLife: 생활 관련 여부
///   - tag: 연관된 태그 (선택사항)
///   - difficulty: 난이도 (1-5)
///   - estimatedTime: 예상 소요 시간 (분)
///   - deadline: 마감 기한
///   - isCompleted: 완료 여부
///   - userId: 소유자 식별자
///   - createdAt: 생성 시간
struct Todo: Identifiable, Codable {
    let id: String
    var raw: String
    var title: String
    var isImportant: Bool
    var isLife: Bool
    var tag: Tag?
    var difficulty: Int
    var estimatedTime: Int
    var deadline: String
    var isCompleted: Bool
    let userId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로  // MongoDB의 tagId를 tag로
        case userId = "user"
        case tag = "tagId"
        case raw, title, isImportant, isLife, difficulty, estimatedTime, deadline, isCompleted, createdAt
    }
}

extension Todo {
    static let mock = Todo(
        id: "new-id",
        raw: "TyTE 10시 반 회의",
        title: "TyTE 10시 반 회의",
        isImportant: false,
        isLife: false,
        tag: Tag(
            id: "mock-tag",
            name: "TyTE",
            color: "F2B749",
            userId: "mock-user"
        ),
        difficulty: 5,
        estimatedTime: 60,
        deadline: Date().apiFormat,
        isCompleted: false,
        userId: "mock-user",
        createdAt: "createdAt"
    )
    
    static let mock1 = Todo(
        id: "new-id1",
        raw: "면접질문 리스트업 및 준비",
        title: "면접질문 리스트업 및 준비",
        isImportant: true,
        isLife: false,
        tag: Tag(
            id: "mock-tag1",
            name: "취업",
            color: "3D44E2",
            userId: "mock-user"
        ),
        difficulty: 5,
        estimatedTime: 120,
        deadline: Date().apiFormat,
        isCompleted: false,
        userId: "mock-user",
        createdAt:"createdAt"
    )
    
    static let mock2 = Todo(
        id: "new-id2",
        raw: "피드백 통한 개선점 확인",
        title: "피드백 통한 개선점 확인",
        isImportant: true,
        isLife: false,
        tag: Tag(
            id: "mock-tag1",
            name: "취업",
            color: "3D44E2",
            userId: "mock-user"
        ),
        difficulty: 4,
        estimatedTime: 40,
        deadline: Date().apiFormat,
        isCompleted: true,
        userId: "mock-user",
        createdAt: "createdAt"
    )
}
