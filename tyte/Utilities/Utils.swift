import SwiftUI
import Foundation

/// DailyStat의 태그 정보를 기반으로 MeshGradient에 사용될 색상 배열을 생성합니다.
///
/// tagStats의 각 태그 색상과 카운트를 기반으로 9개의 색상을 계산하여 반환합니다.
/// 생산성 지수에 따라 색상의 밝기가 조절되며, 특정 순서로 배치됩니다.
///
/// - Parameter dailyStat: 태그 통계와 생산성 지수를 포함한 일일 통계 데이터
///
/// - Returns: MeshGradient를 구성할 9개의 색상 배열
///
/// - Note: 태그가 없는 경우 회색 배열을 반환합니다.
/// - Note: 마지막 색상(8번째 인덱스)은 항상 흰색과 혼합됩니다.
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

/// Todo 목록의 업무와 생활의 시간 비율을 계산합니다.
///
/// 각 Todo의 예상 소요시간을 isLife 속성에 따라 분류하여
/// 전체 시간 대비 각각의 비율을 백분율로 계산합니다.
///
/// - Parameter todos: 계산할 Todo 배열
///
/// - Returns: 업무와 생활의 백분율을 포함하는 튜플
///   - workPercentage: 업무가 차지하는 비율 (0-100)
///   - lifePercentage: 생활이 차지하는 비율 (0-100)
///
/// - Note: 총 시간이 0인 경우 (0, 0)을 반환합니다.
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
