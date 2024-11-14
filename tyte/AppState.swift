import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaultsManager.shared.isLoggedIn
    @Published private(set) var isGuestMode: Bool = false
    @Published private(set) var currentPopup: PopupData?
    @Published private(set) var currentToast: ToastData?
    
    static let shared = AppState()
    
    private init() {}
    
    //MARK: - 메서드
    func showToast(_ type: ToastType, action: (() -> Void)? = nil) {
        currentToast = ToastData(type: type, action: action)
    }
    
    func changeGuestMode(_ state: Bool) {
        isGuestMode = state
    }
    
    func removeToast(){
        currentToast = nil
    }
    
    func showPopup(type: PopupType, action: @escaping () -> Void) {
        currentPopup = PopupData(type: type, action: action)
    }
    
    func removePopup(){
        currentPopup = nil
    }
}
