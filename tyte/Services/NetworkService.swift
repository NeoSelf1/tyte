/// 인증이 필요한 요청과 불필요한 요청을 구분하여 처리합니다.
import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) async throws -> T
    
    func requestWithoutAuth<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?
    ) async throws -> T
}

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
    ) async throws -> T {
        guard !AppState.shared.isGuestMode else {
            throw APIError.isGuestMode
        }
        
        guard NetworkManager.shared.isConnected else {
            throw APIError.networkError
        }
        
        guard let token = KeychainManager.shared.getAccessToken() else {
            throw APIError.unauthorized
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                APIConstants.baseUrl + endpoint.path,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: APIError(afError: error))
                }
            }
        }
    }
    
    /// 인증이 필요없는 API 요청을 처리합니다.
    /// - Parameters:
    ///   - endpoint: API 엔드포인트
    ///   - method: HTTP 메서드
    ///   - parameters: 요청 파라미터
    /// - Returns: 디코딩된 응답 데이터를 포함하는 Publisher
    func requestWithoutAuth<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) async throws -> T {
        guard NetworkManager.shared.isConnected else {
            throw APIError.networkError
        }
        return try await withCheckedThrowingContinuation { continuation in
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
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: APIError(afError: error))
                }
            }
        }
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
