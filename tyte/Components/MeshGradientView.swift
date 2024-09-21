//
//  MeshGradientView.swift
//  tyte
//
//  Created by 김 형석 on 9/10/24.
//

import SwiftUI

struct MeshGradientView: View {
    let colors: [Color]
    let center : SIMD2<Float>
    let isSelected: Bool
    let cornerRadius: CGFloat
    @State private var isAnimating = false
    
    init(
        colors: [Color] = [.red, .purple, .indigo, .orange, .brown, .blue, .yellow, .green, .mint],
        center:SIMD2<Float> = [0.8,0.5],
        isSelected:Bool=false,
        cornerRadius: CGFloat = 6
    ) {
        self.colors = colors
        self.center = center
        self.isSelected = isSelected
        self.cornerRadius = cornerRadius
    }
    
    func calculateCenterPoint() -> SIMD2<Float> {
        if cornerRadius != 6 {
            let offset: Float = 0.3
            let x = isAnimating ? max(0.08, center.x - offset) : min(0.92, center.x + offset)
            let y = isAnimating ? max(0.08, center.y - offset) : min(0.92, center.y + offset)
            return [x, y]
        } else {
            return SIMD2<Float>(center)
        }
    }
    
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
            .rotationEffect(.degrees(isSelected ? 45 : 0))
            .padding(isSelected ? 14 : 20)
            .saturation(isSelected ? 1.0 : 0.5)
            .opacity(isSelected ? 1.0 : 0.5)
            .shadow(color: cornerRadius != 6 ? .gray30 : Color.clear ,radius:24,x:-10,y:10)
            .onAppear {
                if cornerRadius != 6 {
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)){
                        isAnimating = true
                    }
                }
            }
        } else {
            LinearGradientMeshFallback(colors: colors)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .rotationEffect(.degrees(45))
                .padding(isSelected ? 14 : 20)
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
