/// 인증 관련 API 요청을 처리하는 프로토콜입니다.
/// 로그인, 회원가입, 토큰 검증 등의 인증 작업을 담당합니다.
protocol AuthServiceProtocol {
    /// 소셜 로그인 처리
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse
    /// 이메일/패스워드 로그인 처리
    func login(email: String, password: String) async throws -> LoginResponse
    /// 회원가입 처리
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse
    /// 토큰 유효성 검증
    func validateToken(_ token: String) async throws -> ValidateResponse
    /// 계정 삭제
    func deleteAccount() async throws -> EmptyResponse
    /// 이메일 중복 확인
    func checkEmail(_ email: String) async throws -> ValidateResponse
    /// 앱 버전 체크
    func checkVersion() async throws -> VersionResponse
}
