import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    
    // password는 클라이언트에서 저장하지 않습니다.
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email
    }
}
