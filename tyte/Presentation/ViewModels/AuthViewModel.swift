import Foundation
import AuthenticationServices
import GoogleSignIn
import SwiftUI

enum Field: Hashable {
    case email
    case password
    case username
}

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Form State
    
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorText: String = ""
    
    // MARK: - UI State
    
    @Published var isExistingUser: Bool = false
    @Published var isSignUp: Bool = false
    
    @Published var isPasswordWrong: Bool = false
    @Published var isEmailInvalid: Bool = false
    @Published var isUsernameInvalid: Bool = false
    @Published var isPasswordInvalid: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isGoogleLoading: Bool = false
    @Published var isAppleLoading: Bool = false
    
    // MARK: - Computed Properties
    
    var isButtonDisabled: Bool {
        email.isEmpty ||
        (isExistingUser && password.isEmpty) ||
        isEmailInvalid ||
        isPasswordWrong ||
        isLoading
    }
    
    var isSignUpButtonDisabled: Bool {
        username.isEmpty ||
        password.isEmpty ||
        !isUsernameValid ||
        !isPasswordValid ||
        isLoading
    }
    
    // MARK: - Validation Rules
    
    private let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    private let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^.{8,}$")
    private let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9_\u{AC00}-\u{D7A3}\u{3131}-\u{318E}]{3,20}$")
    
    private var isUsernameValid: Bool { usernamePredicate.evaluate(with: username) }
    private var isPasswordValid: Bool { passwordPredicate.evaluate(with: password) }
    
    // MARK: - Dependencies
    
    private let authUseCase: AuthenticationUseCaseProtocol
    
    init(authUseCase: AuthenticationUseCaseProtocol = AuthenticationUseCase()) {
        self.authUseCase = authUseCase
    }
    
    // MARK: - Public Methods
    
    func submit() {
        if isExistingUser {
            login()
        } else {
            if emailPredicate.evaluate(with: email) == false {
                errorText = "이메일 주소가 올바르지 않아요. 오타는 없었는지 확인해 주세요."
                isEmailInvalid = true
            } else {
                checkEmail()
            }
        }
    }
    
    func checkEmail() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                isExistingUser = try await authUseCase.checkEmail(email)
                if !isExistingUser {
                    isSignUp = true
                }
            } catch {
                print("Check email error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
    
    func login() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                _ = try await authUseCase.login(email: email, password: password)
            } catch {
                print("Login error: \(error)")
                if case APIError.wrongPassword = error {
                    errorText = "비밀번호가 맞지 않아요. 천천히 다시 입력해 보세요."
                    isPasswordWrong = true
                } else {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            }
        }
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
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                _ = try await authUseCase.signUp(email: email, username: username, password: password)
            } catch {
                print("Sign up error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
    
    func startGoogleSignIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            ToastManager.shared.show(.error("구글 로그인이 잠시 안되고 있어요. 나중에 다시 시도해주세요."))
            return
        }
        
        isGoogleLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            if let error = error {
                self?.handleGoogleSignInError(error)
            } else if let signInResult = signInResult {
                self?.handleGoogleSignInSuccess(signInResult)
            }
        }
    }
    
    func performAppleLogin(_ result: ASAuthorization) {
        Task {
            isAppleLoading = true
            defer { isAppleLoading = false }
            
            guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let idToken = String(data: identityTokenData, encoding: .utf8) else {
                print("Apple login error: Invalid credentials")
                return
            }
            
            do {
                _ = try await authUseCase.socialLogin(idToken: idToken, provider: "apple")
            } catch {
                print("Apple login error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Private Methods
    
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
        guard let idToken = signInResult.user.idToken?.tokenString else {
            isGoogleLoading = false
            ToastManager.shared.show(.googleError)
            return
        }
        
        Task {
            defer { isGoogleLoading = false }
            
            do {
                _ = try await authUseCase.socialLogin(idToken: idToken, provider: "google")
            } catch {
                print("Google login error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
}
