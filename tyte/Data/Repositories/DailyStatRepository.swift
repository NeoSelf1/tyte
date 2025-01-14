class DailyStatRepository: DailyStatRepositoryProtocol {
    private let remoteDataSource: DailyStatRemoteDataSource
    private let localDataSource: DailyStatLocalDataSource
    
    init(
        remoteDataSource: DailyStatRemoteDataSource,
        localDataSource: DailyStatLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func getSingle(for date: String) async throws -> DailyStat? {
        let localStat = try localDataSource.getDailyStat(for: date)
        
        if NetworkManager.shared.isConnected {
            do {
                let remoteStat = try await remoteDataSource.fetchDailyStat(for: date)
                if let remoteStat = remoteStat {
                    try localDataSource.saveDailyStat(remoteStat)
                }
                return remoteStat
            } catch {
                return localStat
            }
        }
        
        return localStat
    }
    
    func get(in yearMonth: String) async throws -> [DailyStat] {
        let localStats = try localDataSource.getDailyStats(for: yearMonth)
        
        if NetworkManager.shared.isConnected {
            do {
                let remoteStats = try await remoteDataSource.fetchMonthlyStats(in: yearMonth)
                try localDataSource.saveDailyStats(remoteStats)
                return remoteStats
            } catch {
                return localStats
            }
        }
        
        return localStats
    }
    
    func getFriends(for id: String, in yearMonth: String) async throws -> [DailyStat] {
        // Friend stats are only fetched from remote, no local caching
        return try await remoteDataSource.fetchMonthlyStats(for: id, in: yearMonth)
    }
}
