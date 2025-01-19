protocol AuthRemoteDataSourceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse
    func validateToken(_ token: String) async throws -> ValidateResponse
    func checkEmail(_ email: String) async throws -> ValidateResponse
    func deleteAccount() async throws -> EmptyResponse
    func checkVersion() async throws -> VersionResponse
}

/// 사용자 인증 관련 원격 데이터 접근을 담당하는 DataSource입니다.
///
/// 서버와의 통신을 통해 다음 인증 기능을 제공합니다:
/// - 이메일/소셜 로그인
/// - 회원가입
/// - 토큰 검증
/// - 계정 관리
///
/// ## 사용 예시
/// ```swift
/// let authDataSource = AuthRemoteDataSource()
///
/// // 이메일 로그인
/// let loginResponse = try await authDataSource.login(
///     email: "user@example.com",
///     password: "password"
/// )
///
/// // 소셜 로그인
/// let socialResponse = try await authDataSource.socialLogin(
///     idToken: "token",
///     provider: "google"
/// )
/// ```
///
/// ## API Endpoints
/// - POST /auth/login: 이메일 로그인
/// - POST /auth/{provider}: 소셜 로그인
/// - POST /auth/register: 회원가입
/// - POST /auth/validate-token: 토큰 검증
/// - DELETE /auth: 계정 삭제
///
/// ## 관련 타입
/// - ``NetworkAPI``
/// - ``LoginResponse``
/// - ``ValidateResponse``
///
/// - Important: 인증 실패 시 적절한 에러 처리가 필요합니다.
/// - SeeAlso: ``AuthRepository``, ``APIEndpoint``
class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    private let networkAPI: NetworkAPI
    
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = ["email": email, "password": password]
        return try await networkAPI.requestWithoutAuth(.login, method: .post, parameters: parameters)
    }
    
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse {
        let parameters: [String: Any] = ["token": idToken]
        return try await networkAPI.requestWithoutAuth(.socialLogin(provider), method: .post, parameters: parameters)
    }
    
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]
        return try await networkAPI.requestWithoutAuth(.signUp, method: .post, parameters: parameters)
    }
    
    func validateToken(_ token: String) async throws -> ValidateResponse {
        let parameters: [String: Any] = ["token": token]
        return try await networkAPI.requestWithoutAuth(.validateToken, method: .post, parameters: parameters)
    }
    
    func checkEmail(_ email: String) async throws -> ValidateResponse {
        let parameters: [String: Any] = ["email": email]
        return try await networkAPI.requestWithoutAuth(.checkEmail, method: .post, parameters: parameters)
    }
    
    func deleteAccount() async throws -> EmptyResponse {
        return try await networkAPI.request(.deleteAccount, method: .delete, parameters: nil)
    }
    
    func checkVersion() async throws -> VersionResponse {
        return try await networkAPI.requestWithoutAuth(.checkVersion, method: .get, parameters: nil)
    }
}
