import Foundation

protocol DailyStatLocalDataSourceProtocol {
    func getDailyStats(for yearMonth: String) throws -> [DailyStat]
    func getDailyStat(for date: String) throws -> DailyStat?
    func saveDailyStats(_ stats: [DailyStat]) throws
    func saveDailyStat(_ stat: DailyStat) throws
}

/// CoreData를 사용하여 일별 통계 데이터의 로컬 저장소 접근을 관리하는 DataSource입니다.
///
/// 다음과 같은 로컬 데이터 관리 기능을 제공합니다:
/// - 일별/월별 통계 데이터 저장 및 조회
/// - 태그 통계 관계 관리
/// - 데이터 캐싱
///
/// ## 사용 예시
/// ```swift
/// let localDataSource = DailyStatLocalDataSource()
///
/// // 월간 통계 조회
/// let monthlyStats = try localDataSource.getDailyStats(
///     for: "2024-01"
/// )
///
/// // 통계 데이터 저장
/// try localDataSource.saveDailyStat(newStat)
/// ```
///
/// ## 관련 타입
/// - ``CoreDataStack``
/// - ``DailyStatEntity``
/// - ``TagStatEntity``
/// - ``DailyStat``
///
/// - Note: TagStat 관계 설정 시 해당 Tag가 로컬에 존재하지 않으면 연결되지 않습니다.
/// - Note: NSPredicate 사용을 위해 Foundation import가 필요합니다.
/// - SeeAlso: ``DailyStatRemoteDataSource``
class DailyStatLocalDataSource: DailyStatLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
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
    
    /// DailyStat과 TagStat 간의 관계를 설정합니다.
    ///
    /// - Parameters:
    ///   - statEntity: 관계를 설정할 DailyStatEntity
    ///   - tagStats: 연결할 TagStat 배열
    ///
    /// 동작 과정:
    /// 1. 기존 TagStat 관계 모두 제거
    /// 2. 새로운 TagStatEntity 생성 및 관계 설정
    /// 3. 로컬 저장소의 Tag 존재 여부 확인 후 연결
    ///
    /// ```swift
    /// // 예시
    /// let dailyStatEntity = DailyStatEntity(context: context)
    /// try setupTagRelationship(
    ///     for: dailyStatEntity,
    ///     with: [tagStat1, tagStat2]
    /// )
    /// ```
    ///
    /// - Important: Tag가 로컬에 존재하지 않으면 해당 TagStat은 연결되지 않습니다.
    /// 이는 나중에 UI에서 Tag 정보를 표시할 때 문제가 될 수 있으므로, Tag 동기화가 먼저 이루어져야 합니다.
    ///
    /// - Warning: 이 메서드는 트랜잭션 내에서 호출되어야 합니다.
    /// - SeeAlso: ``TagLocalDataSource/saveTag(_:)``
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
