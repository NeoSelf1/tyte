//
//  BalanceNum.swift
//  tyte
//
//  Created by 김 형석 on 9/4/24.
//

import Foundation

struct DailyStat: Codable, Identifiable {
    let id: String
    let date: String
    let userId: String
    let balanceData: BalanceData
    let productivityNum: Double
    let tagStats: [TagStat]
    let center: SIMD2<Float>
     
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case userId = "user"
        case date, balanceData, productivityNum, tagStats, center
    }
    
    static let empty = DailyStat(
        id: UUID().uuidString,
        date: "emptyData",
        userId: "emptyData",
        balanceData: BalanceData(
            title: "Todo가 없네요 :(",
            message: "아래 + 버튼을 눌러 Todo를 추가해주세요",
            balanceNum: 0
        ),
        productivityNum: 0,
        tagStats: [],
        center: SIMD2<Float>(x: 0.5, y: 0.5)
    )
    
    static let dummyStat =
        DailyStat(
            id: "dummy1",
            date: Date().apiFormat,
            userId: "emptyData",
            balanceData: BalanceData(title: "이상적인 하루", message: "오늘의 일정은 그야말로 이상적이에요. 무엇이 좋았는지 기록해두세요.", balanceNum: 90),
            productivityNum: 85.0,
            tagStats: [
                TagStat(id: "tagDummy1", tag: _Tag(id: "tag1", name: "1", color: "FFF700", userId: "dummyUser"), count: 2),
                TagStat(id: "tagDummy2", tag: _Tag(id: "tag2", name: "2", color: "4169E1", userId: "dummyUser"), count: 4),
                TagStat( id: "tagDummy3", tag: _Tag(id: "tag2", name: "3", color: "00CED1", userId: "dummyUser"), count: 3 )],
            center: SIMD2<Float>(0.4, 0.5)
        )
    
}

struct DailyStat_Graph: Identifiable,Codable,Equatable {
    let id: String
    let date: String
    let productivityNum: Double
    
    init(
        date: String,
        productivityNum: Double
    ) {
        self.id = date
        self.date = date
        self.productivityNum = productivityNum
    }
}

struct BalanceData: Codable {
    let title: String 
    let message: String
    let balanceNum: Int
}

struct TagStat: Codable, Identifiable {
    let id: String
    let tag: _Tag
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // tagId를 id로 매핑
        case tag = "tagId"
        case count
    }
}

struct _Tag: Codable, Identifiable {
    let id: String
    let name: String
    let color: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user"
        case color, name
    }
}


