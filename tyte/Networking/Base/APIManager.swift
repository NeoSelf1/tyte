//
//  APIManager.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Alamofire

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
//            private let baseURL = "http://43.201.140.227:8080/api"
    private let baseURL = "http://localhost:8080/api"
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint,
                               method: HTTPMethod = .get,
                               parameters: Parameters? = nil,
                               completion: @escaping (Result<T, APIError>) -> Void) {
        let url = baseURL + endpoint.path
        
        // MARK: Production용
//        guard let token = self.getToken() else {
//            print("Token not valid")
//            return
//        }
        // MARK: 끝
        
        // MARK: Debug 용으로 명시한 임시 사용자 객체. 디버그 완료 시 위 주석으로 대체
        let token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmUzYzQ3ZGNlOTUyOWNiZmZlNDZiODgiLCJpYXQiOjE3MjYyMDM1NTZ9.VlowxWlmN_9_7n2D0fXys3CQ5IbfVzF-h0Ki6vdT6UQ"
//
        // MARK: 끝
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        AF.request(url,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                print("Request Failed in : \(endpoint.path), \(method) -> \(error.localizedDescription)")
                let apiError = APIError(afError: error)
                completion(.failure(apiError))
            }
        }
    }
    
    func requestWithoutAuth<T: Decodable>(_ endpoint: APIEndpoint,
                                          method: HTTPMethod = .post,
                                          parameters: Parameters? = nil,
                                          completion: @escaping (Result<T, APIError>) -> Void) {
        let url = baseURL + endpoint.path
        
        AF.request(url,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                let apiError = APIError(afError: error)
                completion(.failure(apiError))
            }
        }
    }
}
