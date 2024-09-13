//
//  UIImage+Priority.swift
//  tyte
//
//  Created by 김 형석 on 9/2/24.
//

import Foundation
import SwiftUI

extension Int {
//    var text: String {
//        switch self {
//        case 2: return "낮음"
//        case 3: return "높음"
//        default: return "Life"
//        }
//    }
    
    var statusTitleByBalance: String {
        switch self {
        case 71...: return "오늘은 일이 좀 많네요. 그래도 균형을 잃지 않도록 주의해요."
        case 30...70: return "일과 삶이 조화롭게 균형 잡힌 하루네요. 이런 날이 쭉 이어지길!"
        default: return "오늘은 여유로운 날이에요. 개인 시간을 충분히 가질 수 있겠어요."
        }
    }
    
    var statusContentByBalance: String {
        switch self {
        case 71...: return "가족이나 친구와 시간을 보내거나, 취미 활동을 즐겨보는 건 어떨까요?"
        case 30...70: return "오늘의 균형을 유지하는 비결을 메모해두세요. 다른 날에도 활용할 수 있을 거예요."
        default: return "짧은 휴식으로 재충전하는 것을 잊지 마세요. 5분의 명상도 큰 도움이 될 수 있어요."
        }
    }
    
    var colorByBalanceData: Color {
        switch self {
        case 81...: return .red
        case 61...80: return .orange
        case 20...60: return .green
        default: return .gray50
        }
    }
    
    var formattedDuration: String {
        if self < 60 {
            return "\(self)분"
        } else {
            let hours = self / 60
            let remainingMinutes = self % 60
            if remainingMinutes == 0 {
                return "\(hours)시간"
            } else {
                return "\(hours)시간 \(remainingMinutes)분"
            }
        }
    }
}
