/// 사용자 인증 관련 데이터 접근을 관리하는 Repository입니다.
///
/// `AuthRepositoryProtocol`은 다음과 같은 데이터 접근 기능을 제공합니다:
/// - 로그인/회원가입 처리
/// - 토큰 검증
/// - 계정 관리
///
/// ## 사용 예시
/// ```swift
/// let authRepository = AuthRepository()
///
/// // 로그인 요청
/// let response = try await authRepository.login(
///     email: "user@example.com",
///     password: "password"
/// )
///
/// // 토큰 검증
/// let isValid = try await authRepository.validateToken(token)
/// ```
///
/// ## 관련 타입
/// - ``AuthRemoteDataSource``
/// - ``NetworkAPI``
/// - ``APIError``
///
/// - Note: 인증 관련 작업은 항상 네트워크 연결이 필요합니다.
/// - Important: 인증 실패 시 적절한 에러 처리가 필요합니다.
class AuthRepository: AuthRepositoryProtocol {
    
    private let remoteDataSource: AuthRemoteDataSourceProtocol
    
    init(remoteDataSource: AuthRemoteDataSourceProtocol = AuthRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        try await remoteDataSource.login(email: email, password: password)
    }
    
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse {
        try await remoteDataSource.socialLogin(idToken: idToken, provider: provider)
    }
    
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse {
        try await remoteDataSource.signUp(email: email, username: username, password: password)
    }
    
    func validateToken(_ token: String) async throws -> ValidateResponse {
        try await remoteDataSource.validateToken(token)
    }
    
    func checkEmail(_ email: String) async throws -> ValidateResponse {
        try await remoteDataSource.checkEmail(email)
    }
    
    func deleteAccount() async throws {
        try await remoteDataSource.deleteAccount()
    }
    
    func checkVersion() async throws -> VersionResponse {
        try await remoteDataSource.checkVersion()
    }
}
