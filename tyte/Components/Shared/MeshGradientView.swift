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
/// - Note: DayView의 배경과 DetailView의 프리즘 효과로 사용됩니다.
/// - Important: iOS 18 미만 버전에서는 LinearGradient로 자동 대체됩니다.
import SwiftUI

struct MeshGradientView: View {
    @Environment(\.colorScheme) var colorScheme

    private let colors: [Color]
    private let center : SIMD2<Float>
    private let isSelected: Bool
    private let cornerRadius: CGFloat
    
    init(
        colors: [Color] = [.red, .purple, .indigo, .orange, .brown, .blue, .yellow, .green, .mint],
        center:SIMD2<Float> = [0.8,0.5],
        isSelected:Bool = false,
        cornerRadius: CGFloat = 6
    ) {
        self.colors = colors
        self.center = center
        self.isSelected = isSelected
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3, points: [
                    [0.0, 0.0], [0.5, 0], [1.0, 0.0],
                    [0.0, 0.5], SIMD2<Float>(center), [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: colors,
                smoothsColors: true,
                colorSpace: .perceptual
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isSelected ? .gray50 : .clear , lineWidth: 1)
            )
            .rotationEffect(.degrees(45))
            .padding(14)
            .shadow(color: isSelected ? .gray50 : .clear , radius:4,x:0,y:0)
           
        } else {
            LinearGradientMeshFallback(colors: colors)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .rotationEffect(.degrees(45))
                .opacity(1.0)
                .padding(14)
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
