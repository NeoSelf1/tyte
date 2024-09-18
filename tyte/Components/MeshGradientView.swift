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
    
    init(colors: [Color] = [.red, .purple, .indigo, .orange, .brown, .blue, .yellow, .green, .mint], center:SIMD2<Float> = [0.8,0.5], isSelected:Bool=false) {
        self.colors = colors
        self.center = center
        self.isSelected = isSelected
    }
    
    private func optimizeColorDistribution() -> [Color] {
           let requiredColors = 9
           var optimizedColors = [Color](repeating: .clear, count: requiredColors)
           let inputColors = colors
           
           // Define the order of corners and edges
           let orderOfPositions = [0, 2, 6, 8, 1, 3, 5, 7, 4]
           
           for (index, position) in orderOfPositions.enumerated() {
               if index < inputColors.count {
                   optimizedColors[position] = inputColors[index]
               } else {
                   // If we run out of input colors, start filling with the first color again
                   optimizedColors[position] = inputColors[index % inputColors.count]
               }
           }
           
           return optimizedColors
       }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3, height: 3, points: [
                    [0.0, 0.0], [0.5, 0], [1.0, 0.0],
                    [0.0, 0.5], isSelected ? center : [0.5,0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: optimizeColorDistribution(),
                smoothsColors: true,
                colorSpace: .perceptual
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .rotationEffect(.degrees(45))
            .padding(isSelected ? 14 : 20)
            .saturation(isSelected ? 1.0 : 0.5)
            .opacity(isSelected ? 1.0 : 0.5)
        } else {
            LinearGradientMeshFallback(colors: optimizeColorDistribution())
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
