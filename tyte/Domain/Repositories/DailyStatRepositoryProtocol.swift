protocol DailyStatRepositoryProtocol {
    func getSingle(for date: String) async throws -> DailyStat?
    func get(in yearMonth: String) async throws -> [DailyStat]
    func getFriends(for id: String, in yearMonth: String) async throws -> [DailyStat]
}
