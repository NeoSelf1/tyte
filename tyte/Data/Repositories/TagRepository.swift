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
