import Foundation

struct Tag: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    let color: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case userId = "user"
        case name, color
    }
    
    static let mock = Tag(
        id: "mock-tag",
        name: "Mock Tag",
        color: "FF0000",
        userId: "mock-user"
    )
}
