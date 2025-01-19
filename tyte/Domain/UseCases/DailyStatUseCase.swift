import Foundation

protocol DailyStatUseCaseProtocol {
    func getTodayStats() async throws -> DailyStat?
    func getMonthStats(in dateString: String) async throws -> [DailyStat]
    func getMonthStats(in dateString: String, for friendId: String) async throws -> [DailyStat]
    func getProductivityGraph(startDate: Date, endDate: Date) async throws -> [DailyStat_Graph]
}

/// 일별 통계 데이터를 관리하는 Use Case입니다.
///
/// 다음과 같은 통계 관련 기능을 제공합니다:
/// - 일별/월별 통계 조회
/// - 생산성 그래프 데이터 생성
/// - 친구의 통계 데이터 조회
///
/// ## 사용 예시
/// ```swift
/// let dailyStatUseCase = DailyStatUseCase()
///
/// // 오늘의 통계 조회
/// let todayStats = try await dailyStatUseCase.getTodayStats()
///
/// // 월간 통계 조회
/// let monthStats = try await dailyStatUseCase.getMonthStats(
///     in: "2024-01"
/// )
/// ```
///
/// ## 관련 타입
/// - ``DailyStatRepository``
/// - ``DailyStat``
/// - ``DailyStat_Graph``
///
/// - Note: 네트워크 연결 상태에 따라 로컬/리모트 데이터를 적절히 제공합니다.
/// - Note: Date 객체 사용을 위해 Foundation을 import해야 합니다.
/// - SeeAlso: ``TodoUseCase``, 통계 데이터는 Todo 업데이트에 따라 자동으로 갱신됩니다.
class DailyStatUseCase: DailyStatUseCaseProtocol {
    private let repository: DailyStatRepositoryProtocol
    
    init(repository: DailyStatRepositoryProtocol = DailyStatRepository()) {
        self.repository = repository
    }
    
    func getTodayStats() async throws -> DailyStat? {
        let today = Date().apiFormat
        return try await repository.getSingle(for: today)
    }
    
    func getMonthStats(in dateString: String) async throws -> [DailyStat] {
        return try await repository.get(in: String(dateString.prefix(7)))
    }
    
    /// - NOTE: 값을 반환해야하는 메서드는 return 문이 붎요하더라도 명시하여 가독성을 높힙니다.
    func getMonthStats(in dateString: String, for friendId: String) async throws -> [DailyStat] {
        let yearMonth = String(dateString.prefix(7))
        return try await repository.get(in: yearMonth, for: friendId)
    }
    
    func getProductivityGraph(startDate: Date, endDate: Date) async throws -> [DailyStat_Graph] {
        let yearMonth = String(startDate.apiFormat.prefix(7))
        let stats = try await repository.get(in: yearMonth)
        
        return stats.map { stat in
            DailyStat_Graph(
                date: stat.date,
                productivityNum: stat.productivityNum
            )
        }.sorted { $0.date < $1.date }
    }
}
