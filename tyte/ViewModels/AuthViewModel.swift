import Foundation
import Combine
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: AlertItem?
    
    @Published var email: String = "" {didSet{
        if email != oldValue {
            withAnimation (.mediumEaseInOut){
                isPasswordInvalid = false
                isPasswordWrong = false
                isExistingUser = false
                isEmailInvalid = false
                errorText = ""
            }
        }
    }}
    
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

    private let usernamePredicate = NSPredicate(format: "SELF MATCHES %@",
                                        "^[a-zA-Z0-9_]{3,20}$")
    
    @Published var isLoading: Bool = false
    @Published var isSocialLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        checkLoginStatus()
    }
    
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
    
    private func handleError(_ error: Error) {
        guard let apiError = error as? APIError else {
            self.errorMessage = AlertItem(message: error.localizedDescription)
            return
        }
        // switch 문을 통해 특정 에러 처리
        switch apiError {
        case .wrongPassword:
            withAnimation(.mediumEaseInOut){
                errorText = "비밀번호가 맞지 않아요. 천천히 다시 입력해 보세요."
                isPasswordWrong = true
            }
        case .invalidUsername:
            withAnimation(.mediumEaseInOut){
                isUsernameInvalid = true
            }
        case .invalidPassword:
            withAnimation(.mediumEaseInOut){
                isPasswordInvalid = true
            }
        case let error where error.requiresLogout:
            self.errorMessage = AlertItem(message: "로그아웃 필요")
            logout()
        case let error where error.isNetworkError:
            self.errorMessage = AlertItem(message: "네트워크 오류")
        default:
            // switch에서 처리되지 않은 APIError에 대한 기본 처리
            self.errorMessage = AlertItem(message: apiError.localizedDescription)
        }
    }
    
    
    private func checkLoginStatus() {
        print("checkLoginStatus")
        if let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail") {
            do {
                _ = try KeychainManager.retrieve(service: AuthConstants.tokenService, account: savedEmail)
                self.email = savedEmail
                print("isLoggedIn true")
                isLoggedIn = true
            } catch {
                print("isLoggedIn false")
                isLoggedIn = false
            }
        }
    }
    
    func checkEmail(_ email: String) {
        isLoading = true
        errorMessage = nil
        
        authService.checkEmail(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] isExistingUser in
                withAnimation(.mediumEaseOut) {
                    self?.isExistingUser = isExistingUser
                }
                if !isExistingUser {
                    print("navigating to signupview")
                    withAnimation(.mediumEaseOut){
                        self?.isSignUp = true
                    }
                }
            }
            .store(in: &cancellables)
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
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] loginResponse in
                self?.handleSuccessfulLogin(loginResponse: loginResponse)
            }
            .store(in: &cancellables)
    }
    
    func signUp() {
        print("signUp")
        isLoading = true
        errorMessage = nil
        
        authService.signUp(email: email, username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] signUpResponse in
                self?.handleSuccessfulLogin(loginResponse: signUpResponse)
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        guard let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
            print("logout: no savedEmail")
            return
        }
        do {
            try KeychainManager.delete(service: AuthConstants.tokenService,
                                       account: savedEmail)
            // Google 로그아웃
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
            isLoggedIn = false
            email = ""
        } catch {
            errorMessage = AlertItem(message: "일시적인 오류입니다. 잠시 후에 시도해주세요. [05]")
        }
    }
    
    //MARK: - 소셜로그인 관련 메서드
    // 웹을 통해 Google 소셜로그인 진행
    func startGoogleSignIn() {
        print("startGoogleSignIn")
          guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
              errorMessage = AlertItem(message: "Unable to start Google Sign-In process")
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
        print("handleGoogleSignInError")
            if let error = error as? GIDSignInError {
                switch error.code {
                case .canceled:
                    // User canceled the sign-in flow, no need to show an error
                    print("Google Sign-In was canceled by the user")
                case .hasNoAuthInKeychain:
                    errorMessage = AlertItem(message: "No saved Google account found. Please sign in again.")
                default:
                    errorMessage = AlertItem(message: "Google Sign-In failed: \(error.localizedDescription)")
                }
            } else {
                errorMessage = AlertItem(message: "An unknown error occurred during Google Sign-In")
            }
        }
    
    private func handleGoogleSignInSuccess(_ signInResult: GIDSignInResult) {
        print("handleGoogleSignInSuccess")
            if let idToken = signInResult.user.idToken?.tokenString {
                performGoogleLogin(with: idToken)
            } else {
                errorMessage = AlertItem(message: "Failed to get ID token from Google Sign-In")
            }
        }
    
    private func performGoogleLogin(with idToken: String) {
        print("performGoogleLogin")
        isSocialLoading = true
            
            authService.googleLogin(idToken: idToken)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.isSocialLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                } receiveValue: { [weak self] loginResponse in
                    self?.handleSuccessfulLogin(loginResponse: loginResponse)
                }
                .store(in: &cancellables)
        }
    
    private func handleSuccessfulLogin(loginResponse: LoginResponse) {
        do {
            print("handleSuccessfulLogin")
            try KeychainManager.save(token: loginResponse.token,
                                     service: AuthConstants.tokenService,
                                     account: loginResponse.user.email)
            UserDefaults.standard.set(loginResponse.user.email, forKey: "lastLoggedInEmail")
            isLoggedIn = true
            email = loginResponse.user.email
        } catch {
            errorMessage = AlertItem(message: "일시적인 오류입니다. 잠시 후에 시도해주세요. [04]")
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
