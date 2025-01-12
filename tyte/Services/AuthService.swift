import Foundation
import Combine
import Alamofire
/// AuthService는 사용자 인증과 관련된 모든 네트워크 요청을 처리하는 서비스입니다.
/// 회원가입, 로그인, 토큰 검증, 계정 관리 등의 인증 관련 기능을 제공합니다.
class AuthService: AuthServiceProtocol {
    /// 싱글톤 인스턴스
    static let shared = AuthService()
    
    /// 네트워크 요청을 처리하는 서비스
    private let networkService: NetworkServiceProtocol
    
    /// AuthService 초기화
    /// - Parameter networkService: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// 사용자 계정을 삭제합니다.
    /// - Returns: 빈 응답을 포함한 Publisher
    /// - Note: 이 작업은 되돌릴 수 없으며, 모든 사용자 데이터가 영구적으로 삭제됩니다.
    func deleteAccount() -> AnyPublisher<EmptyResponse, APIError> {
        return networkService.request(.deleteAccount, method: .delete, parameters: nil)
    }
    
    /// 인증 토큰의 유효성을 검증합니다.
    /// - Parameter token: 검증할 인증 토큰
    /// - Returns: 토큰 유효성 검증 결과를 포함한 Publisher
    func validateToken(_ token: String) -> AnyPublisher<ValidateResponse, APIError> {
        return networkService.requestWithoutAuth(.validateToken, method: .post, parameters: ["token": token])
    }
    
    /// 이메일 주소의 사용 가능 여부를 확인합니다.
    /// - Parameter email: 확인할 이메일 주소
    /// - Returns: 이메일 사용 가능 여부를 포함한 Publisher
    func checkEmail(_ email: String) -> AnyPublisher<ValidateResponse, APIError> {
        let parameters = ["email": email]
        return networkService.requestWithoutAuth(.checkEmail, method: .post, parameters: parameters)
    }
    
    /// 앱 버전 정보를 확인합니다.
    /// - Returns: 현재 서버에서 지원하는 앱 버전 정보를 포함한 Publisher
    func checkVersion() -> AnyPublisher<VersionResponse, APIError> {
        return networkService.requestWithoutAuth(.checkVersion, method: .get, parameters: nil)
    }
    
    /// 새로운 사용자 계정을 생성합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일 주소
    ///   - username: 사용자 이름
    ///   - password: 계정 비밀번호
    /// - Returns: 생성된 계정의 로그인 정보를 포함한 Publisher
    func signUp(email: String, username: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let parameters: [String: Any] = ["email": email, "username": username, "password": password]
        return networkService.requestWithoutAuth(.signUp, method: .post, parameters: parameters)
    }
    
    /// 소셜 계정을 통해 로그인합니다.
    /// - Parameters:
    ///   - idToken: 소셜 인증 제공자로부터 받은 ID 토큰
    ///   - provider: 소셜 인증 제공자 (예: "google", "apple")
    /// - Returns: 로그인 정보를 포함한 Publisher
    func socialLogin(idToken: String, provider: String) -> AnyPublisher<LoginResponse, APIError> {
        return networkService.requestWithoutAuth(.socialLogin(provider), method: .post, parameters: ["token": idToken])
    }
    
    /// 이메일과 비밀번호로 로그인합니다.
    /// - Parameters:
    ///   - email: 사용자 이메일 주소
    ///   - password: 계정 비밀번호
    /// - Returns: 로그인 정보를 포함한 Publisher
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let parameters: [String: Any] = ["email": email, "password": password]
        return networkService.requestWithoutAuth(.login, method: .post, parameters: parameters)
    }
}
