import Foundation
import Alamofire
import Combine

class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) -> AnyPublisher<T, APIError> {
        return Future { promise in
            if AppState.shared.isGuestMode {
                print("requesting API in guest Mode: returning...")
                promise(.failure(.guestMode))
                return
            }
            guard let token = KeychainManager.shared.getAccessToken() else {
                self.handleUnauthorized()
                promise(.failure(.unauthorized))
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
                    self.handleUnauthorized()
                    promise(.failure(.unauthorized))
                    return
                }
                
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
    
    func requestWithoutAuth<T: Decodable>(_ endpoint: APIEndpoint,
                                          method: HTTPMethod = .get,
                                          parameters: Parameters? = nil) -> AnyPublisher<T, APIError> {
        return Future { promise in
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
    
    private func handleUnauthorized() {
        UserDefaultsManager.shared.logout()
    }
}
