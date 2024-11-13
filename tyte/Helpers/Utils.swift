//
//  Utils.swift
//  tyte
//
//  Created by 김 형석 on 9/11/24.
//
import SwiftUI
import Foundation

func getColors(_ dailyStat: DailyStat) -> [Color] {
    guard !dailyStat.tagStats.isEmpty else {
        return Array(repeating: .gray20, count: 9)
    }
    var colorCounts = [(color: Color.blue30.opacity(0.7), count: 1)]
    colorCounts += dailyStat.tagStats.map { (color: Color(hex: "#\($0.tag.color)"), count: $0.count) }
    
    let totalCount = colorCounts.reduce(0) { $0 + $1.count }
    var resultColors: [Color] = []
    
    for (color, count) in colorCounts {
        let colorCount = Int(round(Double(count) / Double(totalCount) * 9))
        resultColors.append(contentsOf: Array(repeating: color, count: colorCount))
    }
    
    if resultColors.count > 9 {
        resultColors = Array(resultColors.prefix(9))
    } else if resultColors.count < 9 {
        resultColors.append(contentsOf: Array(repeating: colorCounts[0].color, count: 9 - resultColors.count))
    }
    
    let normalizedProductivity = min(max(dailyStat.productivityNum, 0), 80) / 80
    let whiteMixAmount = 1 - normalizedProductivity
    //    let orderOfPositions = [0, 2, 6, 8, 1, 3, 5, 7, 4]
    let orderOfPositions = [0, 1, 2, 8, 5, 7, 6, 4, 3]
    var optimizedColors = [Color](repeating: .clear, count: 9)
    
    for (index, position) in orderOfPositions.enumerated() {
        let baseColor = resultColors[index % resultColors.count]
        if index == 8 {
            optimizedColors[position] = baseColor.mix(with: .white, amount: 0.9)
        } else {
            optimizedColors[position] = baseColor.mix(with: .gray50, amount: whiteMixAmount)
        }
    }
    return optimizedColors
}

func calculateDailyBalance(for todos: [Todo]) -> (workPercentage: Double, lifePercentage: Double) {
    var totalWorkTime: Int = 0
    var totalLifeTime: Int = 0
    
    for todo in todos {
        if todo.isLife {
            totalLifeTime += todo.estimatedTime
        } else {
            totalWorkTime += todo.estimatedTime
        }
    }
    
    let totalTime = totalWorkTime + totalLifeTime
    
    guard totalTime > 0 else {
        return (workPercentage: 0, lifePercentage: 0)
    }
    
    let workPercentage = Double(totalWorkTime) / Double(totalTime) * 100
    let lifePercentage = Double(totalLifeTime) / Double(totalTime) * 100
    
    return (workPercentage: workPercentage, lifePercentage: lifePercentage)
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
