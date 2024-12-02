import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaultsManager.shared.isLoggedIn
    @Published private(set) var isGuestMode: Bool = false
    
    static let shared = AppState()
    
    private init() {}
    
    //MARK: - 메서드
    func changeGuestMode(_ state: Bool) {
        isGuestMode = state
    }
}
