protocol DailyStatRemoteDataSourceProtocol {
    func fetchDailyStat(for date: String) async throws -> DailyStatResponse?
    func fetchMonthlyStats(in yearMonth: String) async throws -> MonthlyStatResponse
    func fetchMonthlyStats(for id: String, in yearMonth: String) async throws -> MonthlyStatResponse
}

/// 일별 통계 데이터에 대한 원격 데이터 접근을 담당하는 DataSource입니다.
///
/// 서버와의 통신을 통해 다음 기능을 제공합니다:
/// - 일별/월별 통계 조회
/// - 친구의 통계 데이터 조회
///
/// ## 사용 예시
/// ```swift
/// let statDataSource = DailyStatRemoteDataSource()
///
/// // 특정 날짜의 통계 조회
/// let stat = try await statDataSource.fetchDailyStat(
///     for: "2024-01-20"
/// )
///
/// // 친구의 월간 통계 조회
/// let stats = try await statDataSource.fetchMonthlyStats(
///     for: "user-123",
///     in: "2024-01"
/// )
/// ```
///
/// ## API Endpoints
/// - GET /dailyStat/{date}: 일별 통계 조회
/// - GET /dailyStat/all/{yearMonth}: 월간 통계 조회
/// - GET /dailyStat/friend/{friendId}/{yearMonth}: 친구의 통계 조회
///
/// ## 관련 타입
/// - ``NetworkAPI``
/// - ``APIEndpoint``
/// - ``DailyStat``
///
/// - Note: 응답이 없는 경우 nil을 반환합니다.
/// - SeeAlso: ``DailyStatRepository``, ``APIEndpoint``
class DailyStatRemoteDataSource: DailyStatRemoteDataSourceProtocol {
    private let networkAPI: NetworkAPI
    
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    func fetchDailyStat(for date: String) async throws -> DailyStat? {
        return try await networkAPI.request(.fetchDailyStatsForDate(date), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(in yearMonth: String) async throws -> [DailyStat] {
        return try await networkAPI.request(.fetchDailyStatsForMonth(yearMonth), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(for id: String, in yearMonth: String) async throws -> [DailyStat] {
        return try await networkAPI.request(
            .getFriendDailyStats(friendId: id, yearMonth: yearMonth),
            method: .get,
            parameters: nil
        )
    }
}
