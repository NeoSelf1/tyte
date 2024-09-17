import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: AlertItem?
    @Published var isLoggedIn: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        checkLoginStatus()
    }
    
    private func checkLoginStatus() {
        if let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail") {
            do {
                _ = try KeychainManager.retrieve(service: AuthConstants.tokenService, account: AuthConstants.tokenAccount(for: savedEmail))
                self.email = savedEmail
                isLoggedIn = true
            } catch {
                isLoggedIn = false
            }
        }
    }
    
    func login(email: String, password: String) {
           self.email = email // 현재 이메일 저장
           
           authService.login(email: email, password: password)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completion in
                   self?.isLoading = false
                   switch completion {
                   case .finished:
                       break
                   case .failure(let error):
                       self?.errorMessage = AlertItem(message: error.localizedDescription)
                   }
               } receiveValue: { [weak self] loginResponse in
                   do {
                       try KeychainManager.save(token: loginResponse.token,
                                                service: AuthConstants.tokenService,
                                                account: AuthConstants.tokenAccount(for: email))
                       UserDefaults.standard.set(email, forKey: "lastLoggedInEmail")
                       self?.isLoggedIn = true
                       self?.username = loginResponse.user.username
                   } catch {
                       self?.errorMessage = AlertItem(message: "Failed to save token")
                   }
               }
               .store(in: &cancellables)
       }
    
    func signUp(username: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signUp(username: username, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = AlertItem(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] signUpResponse in
                do {
                    // 토큰 저장
                    try KeychainManager.save(token: signUpResponse.token,
                                             service: AuthConstants.tokenService,
                                             account: AuthConstants.tokenAccount(for: email))
                    
                    // 마지막 로그인 이메일 저장
                    UserDefaults.standard.set(email, forKey: "lastLoggedInEmail")
                    
                    // 상태 업데이트
                    self?.isLoggedIn = true
                    self?.username = signUpResponse.user.username
                    self?.email = email
                    
                    print("Sign up successful for user: \(signUpResponse.user.username)")
                } catch {
                    self?.errorMessage = AlertItem(message: "Failed to save token after sign up")
                }
            }
            .store(in: &cancellables)
    }
    
    func logout() {
            guard let email = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
                return
            }
            
            do {
                try KeychainManager.delete(service: AuthConstants.tokenService,
                                           account: AuthConstants.tokenAccount(for: email))
                UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
                isLoggedIn = false
                username = ""
                self.email = ""
            } catch {
                errorMessage = AlertItem(message: "Failed to logout")
            }
        }
    
    var isLoginButtonDisabled: Bool {
        return email.isEmpty || isLoading
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
