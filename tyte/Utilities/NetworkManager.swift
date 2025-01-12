/// 애플리케이션의 네트워크 연결 상태를 모니터링하고 관리하는 싱글톤 클래스
///
/// ## `NetworkManager`는 다음과 같은 기능을 제공합니다:
/// - 네트워크 연결 상태 변화 모니터링
/// - Combine을 사용한 네트워크 상태 업데이트 브로드캐스팅
/// - 오프라인 모드 전환 처리
///
/// ## 사용 예시
/// ```swift
/// // 공유 인스턴스 접근
/// let networkManager = NetworkManager.shared
///
/// // 현재 연결 상태 확인
/// if networkManager.isConnected {
///     // 네트워크 작업 수행
/// }
///
/// // 네트워크 상태 변화 구독
/// networkManager.$isConnected
///     .sink { isConnected in
///         if isConnected {
///             print("네트워크 사용 가능")
///         } else {
///             print("네트워크 사용 불가")
///         }
///     }
///     .store(in: &cancellables)
/// ```
///
/// ## 주요 구성요소
/// ### 네트워크 매니저 접근
/// - ``shared``
///
/// ### 속성
/// - ``isConnected``
/// - ``monitor``
///
/// ### 내부 메서드
/// - ``setupNetworkMonitoring()``
/// - ``handleNetworkStatusChange()``
///
/// - Important: 이 클래스는 싱글톤으로 설계되었습니다. 항상 `shared` 인스턴스를 통해 접근해야합니다..
/// - Note: 네트워크 상태 변화는 `isConnected` published 속성을 통해 발행됩니다.
/// - Warning: 네트워크 모니터는 UI 업데이트를 위해 메인 큐 작업이 필요합니다.
import Network
import Combine

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
                print("isConnected: \(isConnected)")
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
