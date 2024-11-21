//
//  Todo.swift
//  tyte
//
//  Created by 김 형석 on 9/1/24.
//

import Foundation


// MARK: Codable = 데이터를 쉽게 인코딩, 디코딩 할 수 있도록 하는 프로토콜 ex. JSON, PropertyList와 Swift 객체 사이의 변환
struct Todo: Identifiable, Codable {
    let id: String
    var raw: String
    var title: String
    var isImportant: Bool
    var isLife: Bool
    var tagId: Tag?
    var difficulty: Int
    var estimatedTime: Int
    var deadline: String
    var isCompleted: Bool
    let user: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로  // MongoDB의 tagId를 tag로
        case raw, tagId, title, isImportant, isLife, difficulty, estimatedTime, deadline, isCompleted, user
    }
}
