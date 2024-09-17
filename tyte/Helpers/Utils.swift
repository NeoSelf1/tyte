//
//  Utils.swift
//  tyte
//
//  Created by 김 형석 on 9/11/24.
//
import SwiftUI
import Foundation

func getColorsForDay(_ dailyStat: DailyStat_DayView) -> [Color] {
    // tagStats가 비어있으면 기본 색상 반환
    guard !dailyStat.tagStats.isEmpty else {
        return Array(repeating: .gray20, count: 9)
    }
    
    // 각 태그의 색상과 카운트를 저장할 배열
    var colorCounts: [(color: Color, count: Int)] = [(color: .blue30.opacity(0.7), count:1)]
    
    // tagStats를 순회하며 색상과 카운트 정보를 저장
    for tagStat in dailyStat.tagStats {
        colorCounts.append((color: Color(hex: "#\(tagStat.tag.color)"), count: tagStat.count))
    }
    
    // 총 카운트 계산
    let totalCount = colorCounts.reduce(0) { $0 + $1.count }
    
    // 결과 색상 배열
    var resultColors: [Color] = []
    
    for (color, count) in colorCounts {
        let colorCount = Int(round(Double(count) / Double(totalCount) * 9))
        resultColors.append(contentsOf: Array(repeating: color, count: colorCount))
    }
    
    // 결과 배열의 크기를 9로 조정
    if resultColors.count > 9 {
        resultColors = Array(resultColors.prefix(9))
    } else if resultColors.count < 9 {
        resultColors.append(contentsOf: Array(repeating: colorCounts.first!.color, count: 9 - resultColors.count))
    }
    
    return resultColors
}


