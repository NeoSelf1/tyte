import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
