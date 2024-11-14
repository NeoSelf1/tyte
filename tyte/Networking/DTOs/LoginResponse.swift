import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}

struct ValidateResponse: Codable {
    let isValid: Bool
}

struct CheckEmailResponse: Decodable {
    let isValid: Bool
}
