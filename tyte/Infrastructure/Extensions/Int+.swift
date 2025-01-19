import Foundation
import SwiftUI

/// Int 값의 표시 형식을 처리하는 확장입니다.
///
/// 다음과 같은 포맷팅 기능을 제공합니다:
/// - 균형 점수에 따른 색상 매핑
/// - 시간 단위 포맷팅
///
/// ## 사용 예시
/// ```swift
/// let score = 85
/// let color = score.colorByBalanceData  // Color.green50
///
/// let minutes = 90
/// let duration = minutes.formattedDuration  // "1시간 30분"
/// ```
///
/// - Note: 균형 점수는 0-100 범위 내에서 처리됩니다.
extension Int {
    var colorByBalanceData: Color {
        switch self {
        case 81...: return .red50
        case 61...80: return .orange50
        case 20...60: return .green50
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
