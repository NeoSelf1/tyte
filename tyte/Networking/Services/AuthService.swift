//
//  AuthService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Combine

class AuthService {
    private let apiManager = APIManager.shared
    
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let endpoint = APIEndpoint.login
        let parameters: [String: Any] = ["email": email, "password": password]
        
        return Future { promise in
            self.apiManager.requestWithoutAuth(endpoint, method: .post, parameters: parameters) { (result: Result<LoginResponse, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(username: String, email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let endpoint = APIEndpoint.signUp
        let parameters: [String: Any] = ["username": username, "email": email, "password": password]
        return Future { promise in
            self.apiManager.requestWithoutAuth(endpoint, method: .post, parameters: parameters) { (result: Result<LoginResponse, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}
