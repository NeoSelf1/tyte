import Foundation
import Combine

class DailyStatService: DailyStatServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDailyStat(for date: String) -> AnyPublisher<DailyStat?, APIError> {
        return networkService.request(.fetchDailyStatsForDate(date), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(yearMonth: String) -> AnyPublisher<MonthlyStatsResponse, APIError> {
        return networkService.request(.fetchDailyStatsForMonth(yearMonth), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(for id: String, in yearMonth: String) -> AnyPublisher<MonthlyStatsResponse, APIError> {
        return networkService.request(.getFriendDailyStats(friendId: id, yearMonth: yearMonth), method: .get, parameters: nil)
    }
}
