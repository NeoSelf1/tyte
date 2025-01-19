import Foundation

/// Todo 항목을 나타내는 데이터 모델입니다.
///
/// 다음과 같은 Todo 정보를 포함합니다:
/// - 기본 정보 (제목, 생성일자, 마감일)
/// - 세부 설정 (중요도, 난이도, 소요시간)
/// - 태그 관계
///
/// ## 사용 예시
/// ```swift
/// // Todo 생성
/// let todo = Todo(
///     id: "todo-1",
///     title: "회의 준비",
///     isImportant: true,
///     difficulty: 3,
///     estimatedTime: 60,
///     deadline: "2024-01-20"
/// )
///
/// // 태그 연결
/// todo.tag = projectTag
/// ```
///
/// ## 관련 타입
/// - ``Tag``
/// - ``TodoRepository``
/// - ``TodoEntity``
///
/// - Note: difficulty는 1-5 범위의 값을 가집니다.
/// - SeeAlso: ``DailyStat``, Todo 완료에 따라 통계가 갱신됩니다.
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
        case id = "_id"  // MongoDB의 _id를 id로
        case userId = "user"
        case tag = "tagId" // MongoDB의 tagId를 tag로
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
