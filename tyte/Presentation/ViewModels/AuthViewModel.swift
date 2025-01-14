import Foundation
import Combine
import AuthenticationServices
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var email: String = "" { didSet {
        if email != oldValue {
                isPasswordInvalid = false
                isPasswordWrong = false
                isExistingUser = false
                isEmailInvalid = false
                errorText = ""
        } } }
    
    @Published var username: String = ""{ didSet {
        if username != oldValue {
                isUsernameInvalid = false
        } } }
    
    @Published var password: String = "" { didSet {
        if password != oldValue {
                isPasswordInvalid = false
                isPasswordWrong = false
        } } }
    
    @Published var errorText: String = ""
    
    @Published var isExistingUser: Bool = false
    @Published var isSignUp: Bool = false
    
    @Published var isPasswordWrong: Bool = false
    @Published var isEmailInvalid: Bool = false
    
    @Published var isUsernameInvalid: Bool = false
    @Published var isPasswordInvalid: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isGoogleLoading: Bool = false
    @Published var isAppleLoading: Bool = false
    
    var isButtonDisabled: Bool {
        email.isEmpty ||
        (isExistingUser && password.isEmpty) ||
        isEmailInvalid ||
        isPasswordWrong ||
        isLoading }
    
    var isSignUpButtonDisabled:Bool {
        username.isEmpty ||
        password.isEmpty ||
        !isUsernameValid ||
        !isPasswordValid ||
        isLoading
    }
    
     let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
     let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^.{8,}$")
     let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9_\u{AC00}-\u{D7A3}\u{3131}-\u{318E}]{3,20}$")
    
    private var isUsernameValid: Bool { return usernamePredicate.evaluate(with: username) }
    private var isPasswordValid: Bool { return passwordPredicate.evaluate(with: password) }
    
    private let authService: AuthServiceProtocol
    
    init(
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.authService = authService
        // TODO: 유효기간 만료와 같은 이유로 토큰 유효하지 않을 경우 필요하나, 네트워크 핸들러에서 자동으로 컷 시키기 때문에 지금은 필요없을듯
        //      checkLoginStatus()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    func submit(){
        if isExistingUser {
            login()
        } else {
            if emailPredicate.evaluate(with: email) == false {
                errorText = "이메일 주소가 올바르지 않아요. 오타는 없었는지 확인해 주세요."
                isEmailInvalid = true
            } else {
                checkEmail(email)
            }
        }
    }
    
    func checkEmail(_ email: String) {
        isLoading = true
        
        authService.checkEmail(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] res in
                guard let self = self else {return}
                isExistingUser = res.isValid
                if !res.isValid {
                    isSignUp = true
                }
            }
            .store(in: &cancellables)
    }
    
    func login() {
        isLoading = true
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    switch error {
                    case .wrongPassword:
                        errorText = "비밀번호가 맞지 않아요. 천천히 다시 입력해 보세요."
                        isPasswordWrong = true
                    default:
                        ToastManager.shared.show(.error(error.localizedDescription))
                    }
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        guard isUsernameValid else {
            isUsernameInvalid = true
            return
        }
        
        guard isPasswordValid else {
            isPasswordInvalid = true
            return
        }
        
        isLoading = true
        
        authService.signUp(email: email, username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] signUpResponse in
                self?.handleSuccessfulLogin(loginResponse: signUpResponse)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 소셜로그인 관련 메서드
    func startGoogleSignIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            ToastManager.shared.show(.error("구글 로그인이 잠시 안되고 있어요. 나중에 다시 시도해주세요."))
            return
        }
        isGoogleLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    self?.handleGoogleSignInError(error)
                } else if let signInResult = signInResult {
                    print(signInResult.description)
                    self?.handleGoogleSignInSuccess(signInResult)
                }
            }
        }
    }
    
    private func handleGoogleSignInError(_ error: Error) {
        isGoogleLoading = false
        if let error = error as? GIDSignInError {
            switch error.code {
            case .canceled:
                print("구글 로그인 도중에 취소됨")
            default:
                ToastManager.shared.show(.googleError)
            }
        } else {
            ToastManager.shared.show(.googleError)
        }
    }
    
    private func handleGoogleSignInSuccess(_ signInResult: GIDSignInResult) {
        if let idToken = signInResult.user.idToken?.tokenString {
            performGoogleLogin(with: idToken)
        } else {
            isGoogleLoading = false
            ToastManager.shared.show(.googleError)
        }
    }
    
    private func performGoogleLogin(with idToken: String) {
        authService.socialLogin(idToken: idToken, provider: "google")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isGoogleLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    func performAppleLogin(_ result: ASAuthorization) {
        isAppleLoading = true
        
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            print("Error: Unexpected credential type")
            isAppleLoading = false
            return
        }
        
        guard let identityTokenData = appleIDCredential.identityToken,
              let idToken = String(data: identityTokenData, encoding: .utf8) else {
            print("Error: Unable to fetch identity token or authorization code")
            isAppleLoading = false
            return
        }
        
        authService.socialLogin(idToken: idToken, provider: "apple")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isAppleLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    private func handleSuccessfulLogin(loginResponse: LoginResponse) {
        KeychainManager.shared.saveToken(loginResponse.token)
        UserDefaultsManager.shared.login(loginResponse.user.id)
    }
}
