import SwiftUI

struct DayView: View {
    let dailyStat: DailyStat?
    let date: Date
    let isToday: Bool
    let isDayVisible: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if let dailyStat = dailyStat {
                MeshGradientView(colors: getColors(dailyStat), center: dailyStat.center, isSelected: isToday, cornerRadius:size/8)
                    .frame(width: size,height: size)
                
                VStack(alignment: .leading, spacing: 0) {
                    balanceIndicator(for: dailyStat)
                    
                    Spacer()
                }
                .frame(width: size, height: size)
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
    
    // 속성 래퍼 = 여러개의 뷰를 선언적 구문 형태로 선언 및 조합해 하나의 뷰 계층 구조를 만들수 있게 해주는 속성 래퍼
    // stat 인자를 받는 함수 형태로 구성했고, Circle, Spacer로 구성된 복합 뷰 구조이기에 ViewBuilder가 유용
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
    
    
    
    // 조건부 렌더링의 경우 @ViewBuilder 불필요
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
