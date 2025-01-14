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
            DailyStat(
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
            request.predicate = NSPredicate(format: "date == %@", stat.date)
            let entity = try coreDataStack.context.fetch(request).first ?? DailyStatEntity(context: coreDataStack.context)
            
            entity.id = stat.id
            entity.date = stat.date
            entity.userId = stat.userId
            entity.productivityNum = stat.productivityNum
            entity.balanceTitle = stat.balanceData.title
            entity.balanceMessage = stat.balanceData.message
            entity.balanceNum = Int16(stat.balanceData.balanceNum)
            entity.centerX = stat.center.x
            entity.centerY = stat.center.y
        }
    }
}
