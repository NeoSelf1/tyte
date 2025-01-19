/// 태그 데이터에 대한 데이터 접근을 관리하는 Repository입니다.
///
/// 다음과 같은 데이터 접근 기능을 제공합니다:
/// - 태그 로컬/리모트 CRUD 작업
/// - 오프라인 동기화 처리
/// - 사용자별 태그 필터링
///
/// ## 사용 예시
/// ```swift
/// let tagRepository = TagRepository()
///
/// // 모든 태그 조회
/// let tags = try await tagRepository.get()
///
/// // 오프라인 상태에서 태그 수정
/// try await tagRepository.updateSingle(modifiedTag)
/// // -> SyncManager가 자동으로 동기화 작업 큐에 추가
/// ```
///
/// ## 관련 타입
/// - ``TagRemoteDataSource``
/// - ``TagLocalDataSource``
/// - ``SyncManager``
///
/// - Note: 오프라인 상태에서의 수정 사항은 SyncManager를 통해 자동으로 동기화됩니다.
/// - SeeAlso: ``TodoRepository``, Todo의 태그 참조 관리에 사용됩니다.
class TagRepository: TagRepositoryProtocol {
    private let remoteDataSource: TagRemoteDataSourceProtocol
    private let localDataSource: TagLocalDataSourceProtocol
    private let syncManager: SyncManager
    
    init(
        remoteDataSource: TagRemoteDataSourceProtocol = TagRemoteDataSource(),
        localDataSource: TagLocalDataSourceProtocol = TagLocalDataSource(),
        syncManager: SyncManager = .shared
    ){
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncManager = syncManager
    }
    
    func get() async throws -> [Tag] {
        let localTags = try localDataSource.getTags()
        
        if NetworkManager.shared.isConnected {
            do {
                let remoteTags = try await remoteDataSource.fetchTags()
                try localDataSource.saveTags(remoteTags)
                return remoteTags
            } catch {
                return localTags
            }
        }
        
        return localTags
    }
    
    func createSingle(name: String, color: String) async throws -> Tag {
        let tag = try await remoteDataSource.createTag(name: name, color: color)
        try localDataSource.saveTag(tag)
        
        return tag
    }
    
    func updateSingle(_ tag: Tag) async throws {
        if NetworkManager.shared.isConnected {
            let updatedTag = try await remoteDataSource.updateTag(tag)
            try localDataSource.saveTag(updatedTag)
        } else {
            try localDataSource.saveTag(tag)
            syncManager.enqueueOperation(.updateTag(tag))
        }
    }
    
    func deleteSingle(_ id: String) async throws {
        if NetworkManager.shared.isConnected {
            _ = try await remoteDataSource.deleteTag(id)
            try localDataSource.deleteTag(id)
        } else {
            try localDataSource.deleteTag(id)
            syncManager.enqueueOperation(.deleteTag(id))
        }
    }
}
