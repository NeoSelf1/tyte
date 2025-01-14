protocol DailyStatServiceProtocol {
    /// 특정 날짜의 통계 데이터 조회
    func fetchDailyStat(for date: String) async throws -> DailyStatResponse?
    /// 월간 통계 데이터 조회
    func fetchMonthlyStats(in yearMonth: String) async throws -> MonthlyStatResponse
    /// 특정 사용자의 월간 통계 데이터 조회
    func fetchMonthlyStats(for id: String, in yearMonth: String) async throws -> MonthlyStatResponse
}

/// DailyStatService는 일일 통계 데이터 관련 네트워크 요청을 처리하는 서비스입니다.
/// 특정 날짜 또는 월 단위의 통계 데이터를 조회하고, 사용자 및 친구의 생산성 통계를 관리합니다.
class DailyStatService: DailyStatServiceProtocol {
    /// 네트워크 요청을 처리하는 서비스
    private let networkService: NetworkServiceProtocol
    
    /// DailyStatService 초기화
    /// - Parameter networkService: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// 특정 날짜의 일일 통계를 조회합니다.
    /// - Parameter date: 조회할 날짜 (형식: "YYYY-MM-DD")
    /// - Returns: 해당 날짜의 통계 데이터를 포함한 Publisher
    /// - Note: 해당 날짜에 통계 데이터가 없는 경우 nil을 반환합니다.
    func fetchDailyStat(for date: String) async throws -> DailyStat? {
        return try await networkService.request(.fetchDailyStatsForDate(date), method: .get, parameters: nil)
    }
    
    /// 특정 월의 전체 통계를 조회합니다.
    /// - Parameter yearMonth: 조회할 연월 (형식: "YYYY-MM")
    /// - Returns: 해당 월의 전체 통계 데이터를 포함한 Publisher
    /// - Note: MonthlyStatsResponse에는 해당 월의 모든 일별 통계가 포함됩니다.
    func fetchMonthlyStats(in yearMonth: String) async throws -> [DailyStat] {
        return try await networkService.request(.fetchDailyStatsForMonth(yearMonth), method: .get, parameters: nil)
    }
    
    /// 특정 친구의 월간 통계를 조회합니다.
    /// - Parameters:
    ///   - id: 조회할 친구의 ID
    ///   - yearMonth: 조회할 연월 (형식: "YYYY-MM")
    /// - Returns: 해당 친구의 월간 통계 데이터를 포함한 Publisher
    /// - Note: 친구의 프라이버시 설정에 따라 일부 데이터가 제한될 수 있습니다.
    func fetchMonthlyStats(for id: String, in yearMonth: String) async throws -> [DailyStat] {
        return try await networkService.request(
            .getFriendDailyStats(friendId: id, yearMonth: yearMonth),
            method: .get,
            parameters: nil
        )
    }
}
