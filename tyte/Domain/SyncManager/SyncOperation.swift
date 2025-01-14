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

/// SyncOperation은 동기화해야 할 작업을 정의하는 구조체입니다.
/// - 작업 타입과 타임스탬프를 포함합니다.
/// - Note:CoreDataSyncService에서는 SyncCommand의 하위속성으로 사용되었으나, 재사용되는 경우가 없어, 기존 SyncCommand 구조체와 통합해 모델을 재구성하였습니다.
struct SyncOperation: Codable {
    let type: SyncOperationType
    
    let createdAt: Date
    var errorMessage: String?
    let id: UUID
    var lastAttempted: Date?
    // entity의 경우 payload 속성이 있으며, encode한 SyncOperation를 담음
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

