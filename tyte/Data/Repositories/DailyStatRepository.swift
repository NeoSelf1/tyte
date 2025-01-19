/// 일별 통계 데이터에 대한 데이터 접근을 관리하는 Repository입니다.
///
/// 다음과 같은 데이터 접근 기능을 제공합니다:
/// - 일별/월별 통계 데이터 조회
/// - 로컬 캐싱 관리
/// - 친구의 통계 데이터 조회
///
/// ## 사용 예시
/// ```swift
/// let statRepository = DailyStatRepository()
///
/// // 특정 날짜의 통계 조회
/// let stat = try await statRepository.getSingle(for: "2024-01-20")
///
/// // 월간 통계 조회 (네트워크 상태에 따라 로컬/리모트 데이터 반환)
/// let stats = try await statRepository.get(in: "2024-01")
/// ```
///
/// ## 관련 타입
/// - ``DailyStatRemoteDataSource``
/// - ``DailyStatLocalDataSource``
/// - ``NetworkManager``
///
/// - Note: 네트워크 연결 상태에 따라 적절한 데이터 소스를 선택하여 데이터를 제공합니다.
/// - Important: 네트워크 연결 시 항상 최신 데이터로 로컬 캐시를 업데이트합니다.
/// - Warning:네트워크 상태에 따라 불필요한 네트워크 호출을 막도록 분기처리를 Repository에서 진행해, UseCase에서 네트워크별 분기처리를 진행하지 않도록 분리하였습니다.
/// - Warning:UseCase에서는 일간 통계정보를 제어 및 접근하기 이전에 필연적으로 월간 통계정보를 서버로부터 fetch하고 있습니다. 불필요한 로컬저장소 접근을 막기위해 일간통계정보 get메서드는 네트워크 연결 시에만 실행됩니다.
class DailyStatRepository: DailyStatRepositoryProtocol {
    private let remoteDataSource: DailyStatRemoteDataSourceProtocol
    private let localDataSource: DailyStatLocalDataSourceProtocol
    
    init(
        remoteDataSource: DailyStatRemoteDataSourceProtocol = DailyStatRemoteDataSource(),
        localDataSource: DailyStatLocalDataSourceProtocol = DailyStatLocalDataSource()
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
    
    func get(in yearMonth: String, for id: String) async throws -> [DailyStat] {
        return try await remoteDataSource.fetchMonthlyStats(for: id, in: yearMonth)
    }
}
