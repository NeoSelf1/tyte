class TagRepository: TagRepositoryProtocol {
    private let remoteDataSource: TagRemoteDataSource
    private let localDataSource: TagLocalDataSource
    private let syncManager: SyncManager
    
    init(
        remoteDataSource: TagRemoteDataSource,
        localDataSource: TagLocalDataSource,
        syncManager: SyncManager
    ) {
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
    
    func updateSingle(_ tag: Tag) async throws -> Tag {
        if NetworkManager.shared.isConnected {
            let updatedTag = try await remoteDataSource.updateTag(tag)
            try localDataSource.saveTag(updatedTag)
            
            return updatedTag
        } else {
            try localDataSource.saveTag(tag)
            syncManager.enqueueOperation(.updateTag(tag))
            
            return tag
        }
    }
    
    func deleteSingle(_ id: String) async throws -> String {
        if NetworkManager.shared.isConnected {
            let deletedTagId = try await remoteDataSource.deleteTag(id)
            try localDataSource.deleteTag(id)
            
            return deletedTagId
        } else {
            try localDataSource.deleteTag(id)
            syncManager.enqueueOperation(.deleteTag(id))
            
            return id
        }
    }
}
