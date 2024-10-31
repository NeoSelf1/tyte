import Foundation
import Combine
import Alamofire

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    private let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService() // 구체적인 apiManager 클래스를 직접 주입하는 것이 아닌, 인터페이스만 하위속성으로 명시 후, 초기화 시 주입
    ) {
        self.networkService = networkService
    }
    
    func deleteAccount(_ email: String) -> AnyPublisher<String, APIError> {
        return networkService.request(.deleteAccount(email), method: .delete, parameters: nil)
    }
    
    func validateToken(_ token: String) -> AnyPublisher<Bool, APIError> {
        return networkService.requestWithoutAuth(.validateToken, method: .post, parameters: ["token": token])
    }
    
    func checkEmail(_ email: String) -> AnyPublisher<Bool, APIError> {
        let parameters = ["email": email]
        return networkService.requestWithoutAuth(.checkEmail, method: .post, parameters: parameters)
    }
    
    func signUp(email: String, username: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let parameters: [String: Any] = ["email": email, "username": username, "password": password]
        return networkService.requestWithoutAuth(.signUp, method: .post, parameters: parameters)
    }
    
    func socialLogin(idToken: String, provider:String) -> AnyPublisher<LoginResponse, APIError> {
        return networkService.requestWithoutAuth(.socialLogin(provider),method: .post, parameters: ["token": idToken])
    }
    

    // NetworkService(구 apiManager)에서 이미 네트워크 통신에 대한 응답 처리 로직이 구현되었음. -> 중복 코드를 제거하였음.
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let parameters: [String: Any] = ["email": email, "password": password]
        return networkService.request(.login, method: .post, parameters: parameters)
    }
    
    // : Legacy
    //    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
    //        let endpoint = APIEndpoint.login
    //        return Future { promise in
    //            self.apiManager.requestWithoutAuth(endpoint,
    //                                               method: .post,
    //                                               parameters: ["email": email, "password": password]) { (result: Result<LoginResponse, APIError>) in
    //                switch result {
    //                case .success(let response):
    //                    self.tokenManager.saveToken(response.token, for: response.user.email)
    //                    promise(.success(response))
    //                case .failure(let error):
    //                    promise(.failure(error))
    //                }
    //            }
    //        }.eraseToAnyPublisher()
    //    }
    
}
