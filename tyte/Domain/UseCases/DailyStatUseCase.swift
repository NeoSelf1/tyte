import Foundation

protocol DailyStatUseCaseProtocol {
    func getTodayStats() async throws -> DailyStat?
    func getMonthStats(in dateString: String) async throws -> [DailyStat]
    func getMonthStats(in dateString: String, for friendId: String) async throws -> [DailyStat]
    func getProductivityGraph(startDate: Date, endDate: Date) async throws -> [DailyStat_Graph]
}

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
    
    /// - NOTE: 값을 명시하는 메서드에는 return 문이 붎요하더라도 명시하여 가독성을 높힙니다.
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
