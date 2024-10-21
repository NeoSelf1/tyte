//
//  APIManager.swift
//  tyte
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    
    private let isDevelopment: Bool = true
    let baseURL: String
    
    private init() {
        baseURL = isDevelopment ? "http://localhost:8080/api" : "http://43.201.140.227:8080/api"
        print("\(baseURL)")
    }
    
    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: "lastLoggedInEmail")
    }
    
    func getToken() -> String? {
        guard let email = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
            return nil
        }
        
        do {
            return try KeychainManager.retrieve(service: AuthConstants.tokenService,
                                                account: email)
        } catch {
            print("Failed to retrieve token: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveToken(_ token: String, for email: String) {
        do {
            try KeychainManager.save(token: token,
                                     service: AuthConstants.tokenService,
                                     account: email)
            UserDefaults.standard.set(email, forKey: "lastLoggedInEmail")
        } catch KeychainManager.KeychainError.unknown(let status) {
            print("Failed to save token. Unknown error with status: \(status)")
        } catch KeychainManager.KeychainError.encodingError {
            print("Failed to save token. Encoding error.")
        } catch {
            print("Failed to save token: \(error.localizedDescription)")
        }
    }
        
    func clearToken() {
        guard let email = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
            return
        }
        
        do {
            try KeychainManager.delete(service: AuthConstants.tokenService,
                                       account: email)
            UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
        } catch {
            print("Failed to clear token: \(error.localizedDescription)")
        }
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint,
                                   method: HTTPMethod = .get,
                                   parameters: Parameters? = nil,
                               completion: @escaping (Result<T, APIError>) -> Void) {
        let url = baseURL + endpoint.path
        var headers: HTTPHeaders = [:]
        if AppState.shared.isGuestMode { return }
        
        // 게스트모드가 아닐 경우, 토큰 접근, 토큰 없을 경우 개발자모드면 임의값 부여, 아닐 경우 에러
        if let token = self.getToken() {
            headers = ["Authorization": "Bearer \(token)"]
        } else {
            if (isDevelopment){
                headers = ["Authorization": "Bearer dummyToken"]
            } else {
                completion(.failure(APIError.unauthorized))
                return
            }
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
                print("Request Failed: \(endpoint.path), \(method) -> \(error.localizedDescription)")
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
 
