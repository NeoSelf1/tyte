import SwiftUI

func getColors(_ dailyStat: DailyStat) -> [Color] {
    guard !dailyStat.tagStats.isEmpty else {
        return Array(repeating: .gray30, count: 9)
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
