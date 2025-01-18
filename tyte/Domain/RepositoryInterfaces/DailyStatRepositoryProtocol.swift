protocol DailyStatRepositoryProtocol {
    func getSingle(for date: String) async throws -> DailyStat?
    func get(in yearMonth: String) async throws -> [DailyStat]
    func get(in yearMonth: String, for id: String) async throws -> [DailyStat]
}
