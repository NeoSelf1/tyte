/// 태그 정보를 기반으로 동적인 그라데이션 효과를 생성하는 시각화 컴포넌트
///
/// iOS 18 이상에서는 MeshGradient를 사용하여 부드러운 그라데이션을 표현하고,
/// 이전 버전에서는 LinearGradient로 대체됩니다.
///
/// - Parameters:
///   - colors: 그라데이션에 사용될 색상 배열
///   - center: 그라데이션의 중심점
///   - isSelected: 선택 상태에 따른 회전 효과 적용 여부
///   - cornerRadius: 모서리 둥글기 정도
///
/// - Note: DayItem의 배경과 DetailSection의 프리즘 효과로 사용됩니다.
/// - Important: iOS 18 미만 버전에서는 LinearGradient로 자동 대체됩니다.
import SwiftUI

struct MeshGradientCell: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme

    var colors: [Color] = [.red, .purple, .indigo, .orange, .brown, .blue, .yellow, .green, .mint]
    var center : SIMD2<Float> = [0.8,0.5]
    var isSelected: Bool = false
    var cornerRadius: CGFloat = 6
    
    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3, points: [
                    [0.0, 0.0], [0.5, 0], [1.0, 0.0],
                    [0.0, 0.5], calculateCenterPoint(), [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: colors,
                smoothsColors: true,
                colorSpace: .perceptual
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.gray50 , lineWidth: 1)
            )
            .rotationEffect(.degrees(isSelected ? 45 : 0))
            .padding(isSelected ? 14 : 20)
            .saturation(isSelected ? 1.0 : 0.5)
            .opacity(isSelected ? 1.0 : 0.5)
            .shadow(color: cornerRadius != 6 ? (colorScheme == .dark ? .gray60 : .gray30) : Color.clear ,radius:24,x:-10,y:10)
            .onAppear {
                if cornerRadius != 6 {
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)){
                        isAnimating = true
                    }
                }
            }
        } else {
            LinearGradientMeshFallback(colors: colors)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.gray50 , lineWidth: 1)
                )
                .rotationEffect(.degrees(isSelected ? 45 : 0))
                .opacity(isSelected ? 1.0 : 0.5)
                .padding(isSelected ? 14 : 20)
        }
    }
    
    func calculateCenterPoint() -> SIMD2<Float> {
        if cornerRadius != 6 {
            let offset: Float = 0.3
            let x = isAnimating ? max(0.1, center.x - offset) : min(0.9, center.x + offset)
            let y = isAnimating ? max(0.1, center.y - offset) : min(0.9, center.y + offset)
            return [x, y]
        } else {
            return SIMD2<Float>(center)
        }
    }
}

struct LinearGradientMeshFallback: View {
    let colors: [Color]
    
    var body: some View {
        ZStack {
            // Diagonal gradients
            LinearGradient(colors: [colors[0], colors[4], colors[8]], startPoint: .topLeading, endPoint: .bottomTrailing)
            LinearGradient(colors: [colors[2], colors[4], colors[6]], startPoint: .topTrailing, endPoint: .bottomLeading)
            
            // Edge gradients
            LinearGradient(colors: [colors[1], colors[4], colors[7]], startPoint: .top, endPoint: .bottom)
            LinearGradient(colors: [colors[3], colors[4], colors[5]], startPoint: .leading, endPoint: .trailing)
        }
        .opacity(0.5) // Blend the gradients
    }
}
