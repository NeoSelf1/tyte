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
    
    private let isDevelopment: Bool
    private let baseURL: String
    
    private init() {
#if DEBUG
        isDevelopment = true
#else
        isDevelopment = false
#endif
        baseURL = isDevelopment ? "http://localhost:8080/api" : "http://43.201.140.227:8080/api"
    }
    
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
        var headers: HTTPHeaders = [
            "Authorization": ""
        ]
        
        if (isDevelopment) {
            headers = [ "Authorization": "Bearer dummyToken" ]
        } else {
            guard let token = self.getToken() else {
                print("Token not valid")
                return
            }
            headers = [ "Authorization": "Bearer \(token)" ]
        }
        
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
