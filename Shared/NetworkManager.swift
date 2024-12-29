import Network
import Combine

class NetworkManager {
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
