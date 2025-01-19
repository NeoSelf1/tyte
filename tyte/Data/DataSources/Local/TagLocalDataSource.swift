import Foundation

protocol TagLocalDataSourceProtocol {
    func getTags() throws -> [Tag]
    func saveTags(_ tags: [Tag]) throws
    func saveTag(_ tag: Tag) throws
    func deleteTag(_ id: String) throws
}

/// CoreData를 사용하여 태그 데이터의 로컬 저장소 접근을 관리하는 DataSource입니다.
///
/// 다음과 같은 로컬 데이터 관리 기능을 제공합니다:
/// - 태그 CRUD 작업
/// - 사용자별 태그 필터링
/// - 마지막 업데이트 시간 관리
///
/// ## 사용 예시
/// ```swift
/// let localDataSource = TagLocalDataSource()
///
/// // 모든 태그 조회
/// let tags = try localDataSource.getTags()
///
/// // 태그 저장
/// try localDataSource.saveTag(newTag)
/// ```
///
/// ## 관련 타입
/// - ``CoreDataStack``
/// - ``TagEntity``
/// - ``Tag``
///
/// - Note: 현재 로그인한 사용자의 태그만 조회됩니다.
/// - Note: NSPredicate 사용을 위해 Foundation import가 필요합니다.
/// - SeeAlso: ``TagRemoteDataSource``
class TagLocalDataSource: TagLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
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
