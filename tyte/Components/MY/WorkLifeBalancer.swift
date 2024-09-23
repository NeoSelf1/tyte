import SwiftUI

struct WorkLifeBalanceBar: View {
    let balance: (workPercentage: Double, lifePercentage: Double)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("워라벨")
                .font(._body3)
                .padding(.leading,2)
                .foregroundStyle(.gray60)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "#FFA500"))
                        .frame(width: CGFloat(balance.workPercentage) / 100 * geometry.size.width)
                    Rectangle()
                        .fill(.blue30.gradient)
                        .frame(width: CGFloat(balance.lifePercentage) / 100 * geometry.size.width)
                }
            }
            .frame(height: 4)
            .cornerRadius(10)
            
            HStack {
                HStack {
                    Circle()
                        .fill(Color(hex: "#FFA500"))
                        .frame(width: 8, height: 8)
                    Text("일 \(String(format: "%.1f", balance.workPercentage))%")
                        .font(._caption)
                        .foregroundStyle(.gray50)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(.blue30)
                        .frame(width: 8, height: 8)
                    Text("생활 \(String(format: "%.1f", balance.lifePercentage))%")
                        .font(._caption)
                        .foregroundStyle(.gray50)
                }
            }
        }
    }
}
