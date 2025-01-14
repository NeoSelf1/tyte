/// - Note:네트워크 상태에 따라 불필요한 네트워크 호출을 막도록 분기처리를 Repository에서 진행해, UseCase에서 네트워크별 분기처리를 진행하지 않도록 분리하였습니다.
/// - Note:UseCase에서는 일간 통계정보를 제어 및 접근하기 이전에 필연적으로 월간 통계정보를 서버로부터 fetch하고 있습니다. 불필요한 로컬저장소 접근을 막기위해 일간통계정보 get메서드는 네트워크 연결 시에만 실행됩니다.
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
    
    /// 네트워크 연결 상태 확인 후, 통신이 가능한 상태이면 최신 일간 통계데이터를 가져오고, 통신 불가능상태일 경우 nil을 반환합니다.
    func getSingle(for date: String) async throws -> DailyStat? {
        guard NetworkManager.shared.isConnected else { return nil }
        
        let remoteStat = try await remoteDataSource.fetchDailyStat(for: date)
        if let remoteStat = remoteStat {
            try localDataSource.saveDailyStat(remoteStat)
        }
        
        return remoteStat
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
