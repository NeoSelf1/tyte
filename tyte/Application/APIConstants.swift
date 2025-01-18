import Foundation

struct APIConstants {
    static let isServerDevelopment = true
    static let isUserDevelopment = true
    static let baseUrl = isServerDevelopment ? "http://localhost:8080/api" : "http://43.201.140.227:8080/api"
}
