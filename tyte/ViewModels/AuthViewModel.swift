import Foundation
import Combine
import AuthenticationServices
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    @ObservedObject private var appState: AppState
    // View와 달리, 뷰모델에서는 비즈니스 로직을 처리하기에 필요한 의존성을 명시적으로 주입 후, 싱글톤으로 접근
    // 필요한 곳에서만 상태를 관찰할 수 있기에 더 효율적
    @Published var currentToast: ToastType?
    @Published var email: String = "" {
        didSet{
            if email != oldValue {
                withAnimation (.mediumEaseInOut){
                    isPasswordInvalid = false
                    isPasswordWrong = false
                    isExistingUser = false
                    isEmailInvalid = false
                    errorText = ""
                }
            }
        }
    }
    
    @Published var username: String = ""{didSet{
        if username != oldValue {
            withAnimation (.mediumEaseInOut){
                isUsernameInvalid = false
            }
        }
    }}
    
    @Published var password: String = "" {didSet{
        if password != oldValue {
            withAnimation (.mediumEaseInOut){
                isPasswordInvalid = false
                isPasswordWrong = false
            }
        }
    }}
    
    @Published var errorText: String = ""
    @Published var isExistingUser: Bool = false
    @Published var isSignUp: Bool = false
    
    @Published var isPasswordWrong: Bool = false
    @Published var isEmailInvalid: Bool = false
    @Published var isUsernameInvalid: Bool = false
    @Published var isPasswordInvalid: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSocialLoading: Bool = false
    
    var isButtonDisabled:Bool {
        email.isEmpty ||
        (isExistingUser && password.isEmpty) ||
        isEmailInvalid ||
        isPasswordWrong ||
        isLoading
    }
    
    var isSignUpButtonDisabled:Bool {
        username.isEmpty ||
        password.isEmpty ||
        isEmailInvalid ||
        isPasswordInvalid ||
        isLoading
    }
    
    private let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    private let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^.{8,}$")
    private let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9_]{3,20}$")
    
    private let authService: AuthService
    
    init(authService: AuthService = AuthService.shared, appState: AppState = .shared) {
        self.authService = authService
        self.appState = appState
        checkLoginStatus()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func submit(){
        if isExistingUser {
            login()
        } else {
            if emailPredicate.evaluate(with: email) == false {
                withAnimation(.mediumEaseInOut){
                    errorText = "이메일 주소가 올바르지 않아요. 오타는 없었는지 확인해 주세요."
                    isEmailInvalid = true
                }
            } else {
                checkEmail(email)
            }
        }
    }
    
    private func checkLoginStatus() {
        if let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail") {
            do {
                let _ = try KeychainManager.retrieve(service: APIConstants.tokenService, account: savedEmail)
                print("isLoggedIn true")
            } catch{
                self.logout()
            }
        } else {
            self.logout()
        }
    }
    
    func checkEmail(_ email: String) {
        isLoading = true
        
        authService.checkEmail(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] isExistingUser in
                withAnimation(.mediumEaseOut) {
                    self?.isExistingUser = isExistingUser
                }
                if !isExistingUser {
                    withAnimation(.mediumEaseOut){
                        self?.isSignUp = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteAccount() {
        isLoading = true
        authService.deleteAccount(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] deleteResponse in
                self?.appState.isLoggedIn = false
            }
            .store(in: &cancellables)
    }
    
    func login() {
        isLoading = true
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    switch error {
                    case .wrongPassword:
                        withAnimation(.mediumEaseInOut){
                            self?.errorText = "비밀번호가 맞지 않아요. 천천히 다시 입력해 보세요."
                            self?.isPasswordWrong = true
                        }
                    default:
                        self?.currentToast = .error(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        isLoading = true
        
        authService.signUp(email: email, username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    switch error {
                    case .invalidPassword:
                        withAnimation(.mediumEaseInOut){
                            self?.isPasswordInvalid = true
                        }
                    case .invalidUsername:
                        withAnimation(.mediumEaseInOut){
                            self?.isUsernameInvalid = true
                        }
                    default:
                        self?.currentToast = .error(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] signUpResponse in
                self?.handleSuccessfulLogin(loginResponse: signUpResponse)
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        do {
            if let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail")  {
                try KeychainManager.delete(service: APIConstants.tokenService,
                                           account: savedEmail)
            }
            
            // Google 로그아웃
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
            // TODO: 여기서 isLoggedIn false로 변화하면, Publishing changes from within view updates is not allowed, this will cause undefined behavior. 발생
            email = ""
            clearAllUserData()
        } catch {
            self.currentToast = .error(error.localizedDescription)
        }
        self.appState.isLoggedIn = false
    }
    
    private func clearAllUserData() {
        // UserDefaults에서 모든 관련 데이터 삭제
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        allKeys.forEach { key in
            if key.starts(with: "com.yourapp.") { // 앱 관련 키에 대해서만 삭제
                defaults.removeObject(forKey: key)
            }
        }
        
        // Keychain에서 모든 관련 데이터 삭제
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: APIConstants.tokenService
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    //MARK: - 소셜로그인 관련 메서드
    // 웹을 통해 Google 소셜로그인 진행
    func startGoogleSignIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            self.currentToast = .error("구글 로그인이 잠시 안되고 있어요. 나중에 다시 시도해주세요.")
            return
        }
        
        isSocialLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            DispatchQueue.main.async {
                self?.isSocialLoading = false
                
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
        if let error = error as? GIDSignInError {
            switch error.code {
            case .canceled:
                print("구글 로그인 도중에 취소됨")
            case .hasNoAuthInKeychain:
                self.currentToast = .googleError
            default:
                self.currentToast = .googleError
                //alertItem = AlertItem(title:"오류",message: "Google Sign-In failed: \(error.localizedDescription)")
            }
        } else {
            self.currentToast = .googleError
            //alertItem = AlertItem(title:"오류",message: "An unknown error occurred during Google Sign-In")
        }
    }
    
    private func handleGoogleSignInSuccess(_ signInResult: GIDSignInResult) {
            if let idToken = signInResult.user.idToken?.tokenString {
                performGoogleLogin(with: idToken)
            } else {
                self.currentToast = .googleError
//                alertItem = AlertItem(title:"오류",message: "Failed to get ID token from Google Sign-In")
            }
        }
    
    private func performGoogleLogin(with idToken: String) {
        isSocialLoading = true
        
        authService.googleLogin(idToken: idToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSocialLoading = false
                if case .failure(let error) = completion {
                    self?.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    func performAppleLogin(_ result: ASAuthorization) {
        isSocialLoading = true
        
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            print("Error: Unexpected credential type")
            isSocialLoading = false
            return
        }
        
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            print("Error: Unable to fetch identity token or authorization code")
            isSocialLoading = false
            return
        }
        
        authService.appleLogin(identityToken: identityToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSocialLoading = false
                if case .failure(let error) = completion {
                    self?.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    private func handleSuccessfulLogin(loginResponse: LoginResponse) {
        do {
            try KeychainManager.save(token: loginResponse.token,
                                     service: APIConstants.tokenService,
                                     account: loginResponse.user.email)
            print("lastLoggedInEmail changed into \(loginResponse.user.email)")
            UserDefaults.standard.set(loginResponse.user.email, forKey: "lastLoggedInEmail")
            appState.isLoggedIn = true
        } catch {
            currentToast = .error(error.localizedDescription)
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
