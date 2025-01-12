import Foundation
import Alamofire
import Combine
/// 인증이 필요한 API 요청을 처리합니다.
/// - Parameters:
///   - endpoint: API 엔드포인트
///   - method: HTTP 메서드
///   - parameters: 요청 파라미터
/// - Returns: 디코딩된 응답 데이터를 포함하는 Publisher
class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) -> AnyPublisher<T, APIError> {
        return Future { promise in
            if AppState.shared.isGuestMode {
                print("requesting API in guest Mode: returning...")
                return
            }
            
            guard NetworkManager.shared.isConnected else {
                self.handleError(.networkError)
                promise(.failure(.networkError))
                return
            }
            
            guard let token = KeychainManager.shared.getAccessToken() else {
                self.handleError(.unauthorized)
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            
            AF.request(
                APIConstants.baseUrl + endpoint.path,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                if let statusCode = response.response?.statusCode, statusCode == 401 {
                    self.handleError(.unauthorized)
                    promise(.failure(.unauthorized))
                    return
                }
                
                switch response.result {
                case .success(let value):
                    promise(.success(value)) // Future의 completion handler 호출
                case .failure(let error):
                    let apiError = APIError(afError: error)
                    self.handleError(apiError)
                    promise(.failure(apiError)) // Future의 completion handler 호출
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 인증이 필요없는 API 요청을 처리합니다.
    /// - Parameters:
    ///   - endpoint: API 엔드포인트
    ///   - method: HTTP 메서드
    ///   - parameters: 요청 파라미터
    /// - Returns: 디코딩된 응답 데이터를 포함하는 Publisher
    func requestWithoutAuth<T: Decodable>(_ endpoint: APIEndpoint,
                                          method: HTTPMethod = .get,
                                          parameters: Parameters? = nil) -> AnyPublisher<T, APIError> {
        return Future { promise in
            guard NetworkManager.shared.isConnected else {
                self.handleError(.networkError)
                promise(.failure(.networkError))
                return
            }
            
            AF.request(
                APIConstants.baseUrl + endpoint.path,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(APIError(afError: error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func handleError(_ error: APIError) {
        DispatchQueue.main.async {
            switch error {
            case .unauthorized:
                UserDefaultsManager.shared.logout()
                break
            case .networkError:
                print("network error")
            default:
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
}
