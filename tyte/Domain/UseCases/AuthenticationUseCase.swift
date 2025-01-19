protocol AuthenticationUseCaseProtocol {
    func login(email: String, password: String) async throws -> User
    func socialLogin(idToken: String, provider: String) async throws -> User
    func signUp(email: String, username: String, password: String) async throws -> User
    func validateToken(_ token: String) async throws -> Bool
    func checkEmail(_ email: String) async throws -> Bool
    func deleteAccount() async throws
    func checkVersion() async throws -> (newVersion: String, minVersion: String)
}

/// 사용자 인증 관련 비즈니스 로직을 처리하는 Use Case입니다.
///
/// 다음과 같은 인증 관련 기능을 제공합니다:
/// - 이메일/패스워드 로그인
/// - 소셜 로그인(Google, Apple)
/// - 회원가입
/// - 토큰 검증
/// - 계정 삭제
///
/// ## 사용 예시
/// ```swift
/// let authUseCase = AuthenticationUseCase()
///
/// // 로그인
/// let user = try await authUseCase.login(
///     email: "user@example.com",
///     password: "password"
/// )
///
/// // 소셜 로그인
/// let user = try await authUseCase.socialLogin(
///     idToken: "token",
///     provider: "google"
/// )
/// ```
///
/// ## 관련 타입
/// - ``AuthRepository``
/// - ``KeychainManager``
/// - ``UserDefaultsManager``
///
/// - Note: 인증 성공 시 토큰은 KeychainManager에, 사용자 정보는 UserDefaultsManager에 저장됩니다.
/// - SeeAlso: ``AuthRepositoryProtocol``
class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    func login(email: String, password: String) async throws -> User {
        let response = try await repository.login(email: email, password: password)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func socialLogin(idToken: String, provider: String) async throws -> User {
        let response = try await repository.socialLogin(idToken: idToken, provider: provider)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func signUp(email: String, username: String, password: String) async throws -> User {
        let response = try await repository.signUp(email: email, username: username, password: password)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func validateToken(_ token: String) async throws -> Bool {
        let response = try await repository.validateToken(token)
        return response.isValid
    }
    
    func checkEmail(_ email: String) async throws -> Bool {
        let response = try await repository.checkEmail(email)
        return response.isValid
    }
    
    func deleteAccount() async throws {
        try await repository.deleteAccount()
        UserDefaultsManager.shared.logout()
    }
    
    func checkVersion() async throws -> (newVersion: String, minVersion: String) {
        let response = try await repository.checkVersion()
        return (newVersion: response.newVersion, minVersion: response.minVersion)
    }
}

private extension AuthenticationUseCase {
    private func handleSuccessfulAuth(_ response: LoginResponse) {
        KeychainManager.shared.saveToken(response.token)
        UserDefaultsManager.shared.login(response.user.id)
    }
}
