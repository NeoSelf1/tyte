import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignUpSuccessful: Bool = false
    @Published var isLoginSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] loginResponse in
                // 로그인 성공 처리
                print("Login successful for user: \(loginResponse.user.username)")
//                print("Login successful for user: \(loginResponse.token)")

                self?.isLoginSuccessful = true
                self?.username = loginResponse.user.username
                
                // 토큰 저장
                UserDefaults.standard.set(loginResponse.token, forKey: "authToken")
                // 사용자 정보 저장 (필요한 경우)
                // UserDefaults.standard.set(loginResponse.user.username, forKey: "username")
                
                // 주의: 실제 앱에서는 UserDefaults 대신 KeyChain을 사용하는 것이 더 안전합니다.
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        isLoading = true
        errorMessage = nil
        print("signUpCalled in AuthViewModel")
        authService.signUp(username: username, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] signUpResponse in
                print("Sign up successful for user: \(signUpResponse.user.username)")
                print("Sign up successful for user: \(signUpResponse.token)")

                self?.isSignUpSuccessful = true
                
                // 여기에서 토큰이나 사용자 정보를 저장할 수 있습니다.
                 UserDefaults.standard.set(signUpResponse.token, forKey: "authToken")
            }
            .store(in: &cancellables)
    }
    
    var isLoginButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty || isLoading
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
