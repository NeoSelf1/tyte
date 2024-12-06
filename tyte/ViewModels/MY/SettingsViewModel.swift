import Foundation
import Combine
import GoogleSignIn

class SettingsViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.authService = authService
    }
    
    func deleteAccount() {
        authService.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
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
