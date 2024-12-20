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
    let user: String
    let balanceData: BalanceData
    let productivityNum: Double
    let tagStats: [TagStat]
    let center: SIMD2<Float>
     
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // MongoDB의 _id를 id로 매핑
        case date, user, balanceData, productivityNum, tagStats, center
    }
    
    static let empty = DailyStat(
        id: UUID().uuidString,
        date: "emptyData",
        user: "emptyData",
        balanceData: BalanceData(
            title: "Todo가 없네요 :(",
            message: "아래 + 버튼을 눌러 Todo를 추가해주세요",
            balanceNum: 0
        ),
        productivityNum: 0,
        tagStats: [],
        center: SIMD2<Float>(x: 0.5, y: 0.5)
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
    let user: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case color, name, user
    }
}
