import Foundation
import Combine
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    private let appState: AppState
    private let authService: AuthServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authService: AuthServiceProtocol = AuthService(),
        appState:AppState = .shared
    ) {
        self.authService = authService
        self.appState = appState
    }
    
    func deleteAccount() {
        authService.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { deleteResponse in
                UserDefaultsManager.shared.logout()
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaultsManager.shared.logout()
    }
}
