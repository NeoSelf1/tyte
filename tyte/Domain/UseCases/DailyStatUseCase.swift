import Foundation

protocol DailyStatUseCaseProtocol {
    func getTodayStats() async throws -> DailyStat?
    func getMonthStats(for date: Date) async throws -> [DailyStat]
    func getFriendMonthStats(friendId: String, date: Date) async throws -> [DailyStat]
    func getProductivityTrend(startDate: Date, endDate: Date) async throws -> [DailyStat_Graph]
}

class DailyStatUseCase: DailyStatUseCaseProtocol {
    private let repository: DailyStatRepository
    
    init(repository: DailyStatRepository) {
        self.repository = repository
    }
    
    func getTodayStats() async throws -> DailyStat? {
        let today = Date().apiFormat
        return try await repository.getSingle(for: today)
    }
    
    func getMonthStats(for date: Date) async throws -> [DailyStat] {
        let yearMonth = String(date.apiFormat.prefix(7))
        return try await repository.get(in: yearMonth)
    }
    
    func getFriendMonthStats(friendId: String, date: Date) async throws -> [DailyStat] {
        let yearMonth = String(date.apiFormat.prefix(7))
        return try await repository.getFriends(for: friendId, in: yearMonth)
    }
    
    func getProductivityTrend(startDate: Date, endDate: Date) async throws -> [DailyStat_Graph] {
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
