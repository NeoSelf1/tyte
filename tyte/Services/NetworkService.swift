//
//  NetworkService.swift
//  tyte
//
//  Created by Neoself on 10/31/24.
//
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
            var headers: HTTPHeaders = [:]
            if AppState.shared.isGuestMode {
                print("requesting API in guest Mode: returning...")
                return
            }
            
            if let token = KeychainManager.shared.getToken() {
                headers = ["Authorization": "Bearer \(token)"]
            } else if APIConstants.isDevelopment {
                headers = ["Authorization": "Bearer dummyToken"]
            } else {
                promise(.failure(.unauthorized))
                return
            }
            
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
}
