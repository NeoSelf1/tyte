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
    let user: String
    var tagId: Tag?
    
    var raw: String
    var title: String
    var isImportant: Bool
    var isLife: Bool
    var difficulty: Int
    var estimatedTime: Int
    var deadline: String
    var isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로  // MongoDB의 tagId를 tag로
        case raw, tagId, title, isImportant, isLife, difficulty, estimatedTime, deadline, isCompleted, user
    }
}

extension Todo {
    init(
        id: String,
        raw: String,
        title: String,
        isImportant: Bool,
        isLife:Bool,
        tagId:Tag,
        difficulty:Int,
        estimatedTime: Int,
        deadline: String,
        isCompleted: Bool,
        user:String
    ) {
        self.id = id
        self.raw = raw
        self.title = title
        self.isImportant = isImportant
        self.isLife = isLife
        self.tagId = tagId
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.user=user
    }
}
