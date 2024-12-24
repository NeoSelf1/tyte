import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaultsManager.shared.isLoggedIn
    @Published var isGuestMode: Bool = false
    
    static let shared = AppState()
    
    private init() {}
}
