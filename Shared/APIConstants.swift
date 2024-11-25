//
//  APIConstants.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//

import Foundation

struct APIConstants {
    static let isServerDevelopment = false
    static let isUserDevelopment = false
    static let baseUrl = isServerDevelopment ? "http://localhost:8080/api" : "http://43.201.140.227:8080/api"
}
