import Network
import Combine

/// 앱의 네트워크 연결 상태를 모니터링하고 관리하는 싱글톤 클래스입니다.
///
/// 다음과 같은 네트워크 관리 기능을 제공합니다:
/// - 실시간 네트워크 상태 모니터링
/// - 연결 타입 판별 (Wi-Fi, Cellular 등)
/// - 오프라인 UI 자동 표시/숨김
///
/// ## 사용 예시
/// ```swift
/// // 네트워크 상태 확인
/// if NetworkManager.shared.isConnected {
///     await fetchRemoteData()
/// }
///
/// // 상태 변화 구독
/// NetworkManager.shared.$isConnected
///     .sink { isConnected in
///         updateUIForConnectivity(isConnected)
///     }
/// ```
///
/// ## 관련 타입
/// - ``OfflineUIManager``
/// - ``NetworkAPI``
///
/// - Note: Network Path Monitor를 사용하여 실시간 상태를 감지합니다.
/// - Important: UI 업데이트는 메인 스레드에서 처리됩니다.
final class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.isConnected = isConnected
                if isConnected {
                    OfflineUIManager.shared.hide()
                } else {
                    OfflineUIManager.shared.show()
                }
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
