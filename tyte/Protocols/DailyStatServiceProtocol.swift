/// 일간 통계 관련 API 요청을 처리하는 프로토콜입니다.
/// 사용자의 활동 통계 데이터 조회를 담당합니다.
protocol DailyStatServiceProtocol {
    /// 특정 날짜의 통계 데이터 조회
    func fetchDailyStat(for date: String) async throws -> DailyStatResponse?
    /// 월간 통계 데이터 조회
    func fetchMonthlyStats(in yearMonth: String) async throws -> MonthlyStatResponse
    /// 특정 사용자의 월간 통계 데이터 조회
    func fetchMonthlyStats(for id: String, in yearMonth: String) async throws -> MonthlyStatResponse
}
