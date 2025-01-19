import Foundation
import SwiftUI

/// 색상 처리를 위한 SwiftUI.Color 확장입니다.
///
/// 다음과 같은 색상 관련 기능을 제공합니다:
/// - HEX 코드로부터 색상 생성
/// - 색상 컴포넌트 추출
/// - 색상 혼합 및 변환
///
/// ## 사용 예시
/// ```swift
/// // HEX 코드로 색상 생성
/// let color = Color(hex: "#FF0000")
///
/// // 색상 혼합
/// let blendedColor = color.mix(with: .blue, amount: 0.5)
///
/// // HEX 코드로 변환
/// let hexString = color.toHex()
/// ```
///
/// - Note: 지원하는 HEX 형식: RGB, RGBA, RRGGBB, RRGGBBAA
/// - SeeAlso: ``UIColor``, UIKit 색상 처리에 사용
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
    
    func mix(with color: Color, amount: CGFloat) -> Color {
        func uiColor(from color: Color) -> UIColor {
            if let cgColor = color.cgColor {
                return UIColor(cgColor: cgColor)
            }
            let components = color.components
            return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.opacity)
        }
        
        let from = uiColor(from: self)
        let to = uiColor(from: color)
        
        guard let blended = from.blend(with: to, alpha: amount) else {
            return self
        }
        
        return Color(blended)
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components!
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

extension UIColor {
    func blend(with color: UIColor, alpha: CGFloat) -> UIColor? {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        
        guard self.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha) else { return nil }
        guard color.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha) else { return nil }
        
        let red = fromRed + (toRed - fromRed) * alpha
        let green = fromGreen + (toGreen - fromGreen) * alpha
        let blue = fromBlue + (toBlue - fromBlue) * alpha
        let alpha = fromAlpha + (toAlpha - fromAlpha) * alpha
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
