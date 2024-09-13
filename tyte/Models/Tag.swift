//
//  Tag.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation

struct Tag: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let color: String
    let user: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case name, color, user
    }
}
