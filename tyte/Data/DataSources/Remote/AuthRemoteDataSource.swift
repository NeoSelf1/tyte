import Foundation

protocol AuthRemoteDataSourceProtocol {
    /// 이메일/패스워드 로그인 처리
    func login(email: String, password: String) async throws -> LoginResponse
    /// 소셜 로그인 처리
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse
    /// 회원가입 처리
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse
    /// 토큰 유효성 검증
    func validateToken(_ token: String) async throws -> ValidateResponse
    /// 계정 삭제
    func checkEmail(_ email: String) async throws -> ValidateResponse
    /// 계정 삭제
    func deleteAccount() async throws -> EmptyResponse
    /// 앱 버전 체크
    func checkVersion() async throws -> VersionResponse
}

/// AuthService는 사용자 인증과 관련된 모든 네트워크 요청을 처리하는 서비스입니다.
/// 회원가입, 로그인, 토큰 검증, 계정 관리 등의 인증 관련 기능을 제공합니다.
class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    // MARK: - Dependencies
    
    private let networkAPI: NetworkAPI
    
    /// AuthService 초기화
    /// - Parameter NetworkAPI: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    /// 이메일과 비밀번호로 로그인합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일 주소
    ///   - password: 계정 비밀번호
    /// - Returns: 로그인 정보를 포함한 Publisher
    func login(email: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = ["email": email, "password": password]
        return try await networkAPI.requestWithoutAuth(.login, method: .post, parameters: parameters)
    }
    
    /// 소셜 계정을 통해 로그인합니다.
    /// - Parameters:
    ///   - idToken: 소셜 인증 제공자로부터 받은 ID 토큰
    ///   - provider: 소셜 인증 제공자 (예: "google", "apple")
    /// - Returns: 로그인 정보를 포함한 Publisher
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse {
        let parameters: [String: Any] = ["token": idToken]
        return try await networkAPI.requestWithoutAuth(.socialLogin(provider), method: .post, parameters: parameters)
    }
    
    /// 새로운 사용자 계정을 생성합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일 주소
    ///   - username: 사용자 이름
    ///   - password: 계정 비밀번호
    /// - Returns: 생성된 계정의 로그인 정보를 포함한 Publisher
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]
        return try await networkAPI.requestWithoutAuth(.signUp, method: .post, parameters: parameters)
    }
    
    /// 인증 토큰의 유효성을 검증합니다.
    /// - Parameter token: 검증할 인증 토큰
    /// - Returns: 토큰 유효성 검증 결과를 포함한 Publisher
    func validateToken(_ token: String) async throws -> ValidateResponse {
        let parameters: [String: Any] = ["token": token]
        return try await networkAPI.requestWithoutAuth(.validateToken, method: .post, parameters: parameters)
    }
    
    /// 이메일 주소의 사용 가능 여부를 확인합니다.
    /// - Parameter email: 확인할 이메일 주소
    /// - Returns: 이메일 사용 가능 여부를 포함한 Publisher
    func checkEmail(_ email: String) async throws -> ValidateResponse {
        let parameters: [String: Any] = ["email": email]
        return try await networkAPI.requestWithoutAuth(.checkEmail, method: .post, parameters: parameters)
    }
    
    /// 사용자 계정을 삭제합니다.
    /// - Returns: 빈 응답을 포함한 Publisher
    /// - Note: 이 작업은 되돌릴 수 없으며, 모든 사용자 데이터가 영구적으로 삭제됩니다.
    func deleteAccount() async throws -> EmptyResponse {
        return try await networkAPI.request(.deleteAccount, method: .delete, parameters: nil)
    }
    
    /// 앱 버전 정보를 확인합니다.
    /// - Returns: 현재 서버에서 지원하는 앱 버전 정보를 포함한 Publisher
    func checkVersion() async throws -> VersionResponse {
        return try await networkAPI.requestWithoutAuth(.checkVersion, method: .get, parameters: nil)
    }
}
