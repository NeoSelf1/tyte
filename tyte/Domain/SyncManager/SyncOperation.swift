import Foundation

enum SyncStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case failed
    case maxRetriesExceeded
}

enum SyncOperationType: Codable {
    case updateTodo(Todo)
    case deleteTodo(String)
    
    case updateTag(Tag)
    case deleteTag(String)
}

/// Todo 동기화 작업을 정의하는 데이터 모델입니다.
///
/// 다음과 같은 동기화 정보를 포함합니다:
/// - 작업 유형 (Todo/Tag 수정/삭제)
/// - 작업 상태 및 타임스탬프
/// - 재시도 정보
///
/// ## 사용 예시
/// ```swift
/// // Todo 수정 작업 생성
/// let operation = SyncOperation(
///     type: .updateTodo(modifiedTodo)
/// )
///
/// // Tag 삭제 작업 생성
/// let operation = SyncOperation(
///     type: .deleteTag(tagId)
/// )
/// ```
///
/// ## 관련 타입
/// - ``SyncStatus``
/// - ``SyncOperationType``
/// - ``SyncManager``
///
/// - Note: 최대 재시도 횟수는 3회입니다.
/// - Note:CoreDataSyncService에서는 SyncCommand의 하위속성으로 사용되었으나, 재사용되는 경우가 없어, 기존 SyncCommand 구조체와 통합해 모델을 재구성하였습니다.
/// - SeeAlso: ``SyncManager``, 실제 동기화 처리에 사용
struct SyncOperation: Codable {
    let type: SyncOperationType
    
    let createdAt: Date
    var errorMessage: String?
    let id: UUID
    var lastAttempted: Date?
    var retryCount: Int
    var status: SyncStatus
    
    init(type: SyncOperationType) {
        self.id = UUID()
        self.type = type
        self.createdAt = Date()
        self.retryCount = 0
        self.status = .pending
    }
}

