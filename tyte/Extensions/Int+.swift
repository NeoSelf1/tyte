//
//  UIImage+Priority.swift
//  tyte
//
//  Created by 김 형석 on 9/2/24.
//

import Foundation
import SwiftUI

extension Int {
    var colorByBalanceData: Color {
        switch self {
        case 81...: return .red0
        case 61...80: return .orange0
        case 20...60: return .green0
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
