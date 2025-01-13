import SwiftUI

struct DayItem_Widget: View {
    var dailyStat: DailyStat?
    var date: Date
    var isToday: Bool
    var isDayVisible: Bool
    var size: CGFloat
    var isCircleVisible: Bool = true
    
    var body: some View {
        ZStack {
            if let dailyStat = dailyStat {
                MeshGradientCell_Widget(
                    colors: getColors(dailyStat),
                    center: dailyStat.center,
                    isSelected: isToday,
                    cornerRadius:size/8
                )
                .frame(width: size,height: size)
                
                if isCircleVisible{
                    VStack(alignment: .leading, spacing: 0) {
                        balanceIndicator(for: dailyStat)
                        
                        Spacer()
                    }
                    .frame(width: size, height: size)
                }
            } else {
                Rectangle()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .rotationEffect(.degrees(45))
                    .padding(14)
                    .foregroundStyle(.gray30)
                    .frame(width:size,height:size)
            }
        }
    }
    
    private var dateText: some View {
        VStack (alignment: .center, spacing:0) {
            Text(date.formattedDay)
                .font(isToday ? ._body4 : ._caption)
                .overlay(todayIndicator(), alignment: .bottom)
                .foregroundColor(.gray90)
            
            if isDayVisible {
                Text(date.weekdayString)
                    .font(._caption)
                    .foregroundColor(.gray50)
            }
        }
        .offset(y: isDayVisible ? 10 : 0)
        .padding(.leading, 44)
    }
    
    private func balanceIndicator(for stat: DailyStat) -> some View {
        HStack {
            Circle()
                .fill(stat.balanceData.balanceNum.colorByBalanceData)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
                .padding(.leading, 8)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func todayIndicator() -> some View {
        if isToday {
            Rectangle()
                .fill(.gray90)
                .frame(height: 2)
                .offset(y: 0)
        }
    }
}

private struct MeshGradientCell_Widget: View {
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
            LinearGradientMeshFallback_Widget(colors: colors)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .rotationEffect(.degrees(45))
                .opacity(1.0)
                .padding(14)
        }
    }
}

struct LinearGradientMeshFallback_Widget: View {
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
