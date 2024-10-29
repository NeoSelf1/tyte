import Foundation

enum RelationshipStatus: String, Codable {
    case active
    case blocked
    case appending
}

struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUser: User
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fromUser
        case status
    }
}
