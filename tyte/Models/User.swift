//
//  User.swift
//  tyte
//
//  Created by Neoself on 10/23/24.
//
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email
    }
}

struct SearchResult: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let isFriend: Bool
    var isPending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case username, email, isFriend, isPending
    }
}
