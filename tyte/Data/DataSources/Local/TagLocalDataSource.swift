import Foundation

protocol TagLocalDataSourceProtocol {
    func getTags() throws -> [Tag]
    func saveTags(_ tags: [Tag]) throws
    func saveTag(_ tag: Tag) throws
    func deleteTag(_ id: String) throws
}

class TagLocalDataSource: TagLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getTags() throws -> [Tag] {
        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", UserDefaultsManager.shared.currentUserId ?? "")
        
        let entities = try coreDataStack.context.fetch(request)
        return entities.map { entity in
            Tag(
                id: entity.id ?? "",
                name: entity.name ?? "",
                color: entity.color ?? "",
                userId: entity.userId ?? ""
            )
        }
    }
    
    func saveTags(_ tags: [Tag]) throws {
        try coreDataStack.performInTransaction {
            for tag in tags {
                try saveTag(tag)
            }
        }
    }
    
    func saveTag(_ tag: Tag) throws {
        try coreDataStack.performInTransaction {
            let request = TagEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", tag.id)
            
            let entity = try coreDataStack.context.fetch(request).first ?? TagEntity(context: coreDataStack.context)
            
            entity.id = tag.id
            entity.name = tag.name
            entity.color = tag.color
            entity.userId = tag.userId
            entity.lastUpdated = Date().koreanDate
        }
    }
    
    func deleteTag(_ id: String) throws {
        try coreDataStack.performInTransaction {
            let request = TagEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            if let entity = try coreDataStack.context.fetch(request).first {
                coreDataStack.context.delete(entity)
            }
        }
    }
}
