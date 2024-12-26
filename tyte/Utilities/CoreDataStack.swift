//
//  CoreDataStack.swift
//  tyte
//
//  Created by Neoself on 12/26/24.
//
import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext
    
    private init() {
        let container = NSPersistentContainer(name: "tyte")
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        persistentContainer = container
        context = container.viewContext
    }
    
    
    /// 트랜잭션 내에서 작업을 수행하고 자동으로 저장 또는 롤백을 처리하는 메서드
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
                // 오류 발생 시 롤백
                context.rollback()
                throw error
            }
        }
    }
}

/// TodoEntity의 tag 속성이 옵셔널 Tag 타입이라 직접 toDomain 변환 없이는 타입이 맞지 않음.
extension TagEntity {
    func toDomain() -> Tag {
        return Tag(
            id: id ?? "",
            name: name ?? "",
            color: color ?? "",
            userId: userId ?? ""
        )
    }
}
