import Foundation

protocol DailyStatLocalDataSourceProtocol {
    func getDailyStats(for yearMonth: String) throws -> [DailyStat]
    func getDailyStat(for date: String) throws -> DailyStat?
    func saveDailyStats(_ stats: [DailyStat]) throws
    func saveDailyStat(_ stat: DailyStat) throws
}

class DailyStatLocalDataSource: DailyStatLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getDailyStats(for yearMonth: String) throws -> [DailyStat] {
        let request = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date BEGINSWITH %@", yearMonth)
        let entities = try coreDataStack.context.fetch(request)
        return entities.map { entity in
            
            let tagStats: [TagStat] = (entity.tagStats as? Set<TagStatEntity>)?.map { tagStatEntity in
                TagStat(
                    id: tagStatEntity.id ?? "",
                    tag: Tag(
                        id: tagStatEntity.tag?.id ?? "",
                        name: tagStatEntity.tag?.name ?? "",
                        color: tagStatEntity.tag?.color ?? "",
                        userId: tagStatEntity.tag?.userId ?? ""
                    ),
                    count: Int(tagStatEntity.count)
                )
            } ?? []
            
            return DailyStat(
                id: entity.id ?? "",
                date: entity.date ?? "",
                userId: entity.userId ?? "",
                balanceData: BalanceData(
                    title: entity.balanceTitle ?? "",
                    message: entity.balanceMessage ?? "",
                    balanceNum: Int(entity.balanceNum)
                ),
                productivityNum: entity.productivityNum,
                tagStats: tagStats,
                center: SIMD2<Float>(entity.centerX, entity.centerY)
            )
        }
    }
    
    func getDailyStat(for date: String) throws -> DailyStat? {
        let request = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date)
        if let entity = try coreDataStack.context.fetch(request).first {
            return DailyStat(
                id: entity.id ?? "",
                date: entity.date ?? "",
                userId: entity.userId ?? "",
                balanceData: BalanceData(
                    title: entity.balanceTitle ?? "",
                    message: entity.balanceMessage ?? "",
                    balanceNum: Int(entity.balanceNum)
                ),
                productivityNum: entity.productivityNum,
                tagStats: [], // Add tag stats mapping if needed
                center: SIMD2<Float>(entity.centerX, entity.centerY)
            )
        }
        return nil
    }
    
    func saveDailyStats(_ stats: [DailyStat]) throws {
        try coreDataStack.performInTransaction {
            for stat in stats {
                try saveDailyStat(stat)
            }
        }
    }
    
    func saveDailyStat(_ stat: DailyStat) throws {
        try coreDataStack.performInTransaction {
            let request = DailyStatEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@ AND userId == %@", stat.date, stat.userId)
            
            if let existingEntity = try coreDataStack.context.fetch(request).first {
                coreDataStack.context.delete(existingEntity)
            }
            
            let entity = DailyStatEntity(context: coreDataStack.context)
            entity.id = stat.id
            entity.date = stat.date
            entity.userId = stat.userId
            entity.productivityNum = stat.productivityNum
            entity.balanceTitle = stat.balanceData.title
            entity.balanceMessage = stat.balanceData.message
            entity.balanceNum = Int16(stat.balanceData.balanceNum)
            entity.centerX = stat.center.x
            entity.centerY = stat.center.y
            
            try setupTagRelationship(for: entity, with: stat.tagStats)
        }
    }
    
    private func setupTagRelationship(for statEntity: DailyStatEntity, with tagStats: [TagStat]) throws {
        if let existingStats = statEntity.tagStats as? Set<TagStatEntity> {
            for stat in existingStats {
                statEntity.removeFromTagStats(stat)
                coreDataStack.context.delete(stat)
            }
        }
        
        for tagStat in tagStats {
            let tagStatEntity = TagStatEntity(context: coreDataStack.context)
            tagStatEntity.id = tagStat.id
            tagStatEntity.count = Int16(tagStat.count)
            
            /// - Note: Tag 관계 설정 -> 여기서 local 저장소에 tagStat에 명시된 id값을 지닌 tag가 없을 경우, tag가 연결되지 않음에 따라 버그 발생
            let tagRequest = TagEntity.fetchRequest()
            tagRequest.predicate = NSPredicate(format: "id == %@", tagStat.tag.id)
            
            if let tagEntity = try coreDataStack.context.fetch(tagRequest).first {
                tagStatEntity.tag = tagEntity
                statEntity.addToTagStats(tagStatEntity)
                tagStatEntity.dailyStat = statEntity
            }
        }
    }
}
