import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaultsManager.shared.isLoggedIn
    @Published private(set) var isGuestMode: Bool = false
    
    static let shared = AppState()
    
    @Published var currentToast: ToastType?
}
