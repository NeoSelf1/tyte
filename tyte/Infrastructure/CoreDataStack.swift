import Foundation
import CoreData

/// Core Data 영구 저장소를 관리하는 싱글톤 클래스입니다.
///
/// 앱의 로컬 데이터베이스를 관리하며, 트랜잭션 처리와 데이터 정리 기능을 제공합니다.
/// App Group을 통해 위젯과 데이터베이스를 공유합니다.
///
/// - Important: DataModel.sqlite 파일은 App Group 컨테이너에 저장됩니다.
/// - Warning: Context 작업은 반드시 performInTransaction 메서드를 통해 수행해야 합니다.
final class CoreDataStack {
    static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext
    
    private init() {
        persistentContainer = {
            let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neox.tyte")!
            let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("DataModel.sqlite"))
            
            let container = NSPersistentContainer(name: "tyte")
            container.persistentStoreDescriptions = [storeDescription]
            
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
    
        context = persistentContainer.viewContext
    }
    
    /// 트랜잭션 내에서 작업을 수행하고 자동으로 저장 또는 롤백을 처리하는 메서드
    ///
    /// - Parameter block: 트랜잭션 내에서 실행할 작업
    /// - Throws: 작업 수행 중 발생한 오류
    func performInTransaction(_ block: () throws -> Void) throws {
        // 컨텍스트에서 동기적으로 작업 수행
        try context.performAndWait {
            do {
                // 작업 실행
                try block()
                // 변경사항이 있는 경우에만 저장
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                context.rollback()
                throw error
            }
        }
    }
    
    /// 특정 사용자의 모든 데이터를 삭제합니다.
    ///
    /// - Parameter userId: 삭제할 데이터의 사용자 ID
    /// - Throws: 데이터 삭제 중 발생한 오류
    func clearUserData(for userId: String) throws {
        let entities = ["TodoEntity", "TagEntity", "DailyStatEntity", "TagStatEntity", "SyncOperationEntity"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
    }
}


/// TagEntity를 도메인 모델 Tag로 변환하는 확장입니다.
extension TagEntity {

    /// TagEntity를 Tag 도메인 모델로 변환합니다.
    /// - Returns: 변환된 Tag 객체
    func toDomain() -> Tag {
        return Tag(
            id: id ?? "",
            name: name ?? "",
            color: color ?? "",
            userId: userId ?? ""
        )
    }
}
