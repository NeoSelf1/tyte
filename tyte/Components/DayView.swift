import SwiftUI

struct DayView: View {
    let dailyStats: [DailyStat_DayView]
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    private var dailyStat: DailyStat_DayView? {
        dailyStats.first { date.apiFormat == $0.date }
    }
    
    private var gradientColors: [Color] {
        dailyStat.map { getColorsForDay($0) } ?? [.gray20]
    }
    
    private var center: SIMD2<Float> {
        dailyStat?.center ?? [0.5, 0.5]
    }
    
    var body: some View {
        ZStack {
            MeshGradientView(colors: gradientColors, center: center, isSelected: isSelected)
            
            VStack(alignment: .leading, spacing: 0) {
                if let stat = dailyStat {
                    balanceIndicator(for: stat)
                }
                
                Spacer()
                
                dateText
            }
        }
        .frame(width: 64, height: 64)
    }
    
    // 속성 래퍼 = 여러개의 뷰를 선언적 구문 형태로 선언 및 조합해 하나의 뷰 계층 구조를 만들수 있게 해주는 속성 래퍼
    // stat 인자를 받는 함수 형태로 구성했고, Circle, Spacer로 구성된 복합 뷰 구조이기에 ViewBuilder가 유용
    @ViewBuilder
    private func balanceIndicator(for stat: DailyStat_DayView) -> some View {
        HStack {
            Circle()
                .fill(stat.balanceData.balanceNum.colorByBalanceData)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
                .padding(.leading, 6)
            
            Spacer()
        }
    }
    
    private var dateText: some View {
        Text(date.formattedDay)
            .font(isSelected || isToday ? ._subhead2 : ._body2)
            .overlay(todayIndicator(), alignment: .bottom)
            .padding(.leading, 44)
            .padding(.bottom, 3)
            .foregroundColor(.gray90)
    }
    
    // 조건부 렌더링의 경우 @ViewBuilder 불필요
    @ViewBuilder
    private func todayIndicator() -> some View {
        if isToday {
            Rectangle()
                .fill(.gray90)
                .frame(height: 3)
                .offset(y: 1)
        }
    }
}