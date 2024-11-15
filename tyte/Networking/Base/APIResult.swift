//
//  APIResult.swift
//  tyte
//
//  Created by Neoself on 11/15/24.
//
import Foundation

enum APIResult<T: Decodable> {
    case success(T)
    case failure(Error)  // 일반적인 Error 프로토콜 사용
    
    init(statusCode: Int, data: Data) throws {
        let decoder = JSONDecoder()
        
        switch statusCode {
        case 200..<300:
            let response = try decoder.decode(T.self, from: data)
            self = .success(response)
        default:
            throw APIError.unknown
        }
    }
}
