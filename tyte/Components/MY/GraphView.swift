import SwiftUI
import Charts

struct GraphView: View {
    // MARK: @State 프로토콜 변수가 변경되면 뷰를 다시 그림.
    @ObservedObject var viewModel : MyPageViewModel
    
    
    var body: some View {
        // MARK: New Chart API
        VStack(alignment: .leading, spacing:0 ){
            HStack(alignment:.top) {
                Text(viewModel.currentDate.formattedMonth)
                    .font(._headline2)
                    .foregroundStyle(.gray90)
                
                Spacer()
                
                VStack (alignment: .leading){
                    Text("\(viewModel.graphData.reduce(0) {$0 + $1.productivityNum}.formatted())")
                        .font(._subhead2)
                        .foregroundStyle(.gray90)
                    
                    Text("총 생산지수")
                        .font(._body3)
                        .foregroundStyle(.gray50)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            if (viewModel.graphData.isEmpty){
                Text("데이터가 없어요!")
                    .font(._body3)
                    .foregroundStyle(.gray50)
                    .frame(maxWidth: .infinity, maxHeight: 250, alignment: .center)
                    .padding(.horizontal)
                
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        AnimatedChart()
                            .frame(width: UIScreen.main.bounds.width - 40, alignment: .trailing)
                            .id("chart")
                            .scaleEffect(animationAmount)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {
        let max:Int = Int(viewModel.graphData.max { item1, item2 in
            return item2.productivityNum > item1.productivityNum
        }?.productivityNum ?? 0)
        
        Chart {
            ForEach(viewModel.graphData){ dailyStat in
                LineMark(
                    x: .value("Date", dailyStat.date.parsedDate),
                    y: .value("ProductivityNum", dailyStat.animate ? dailyStat.productivityNum : 0)
                )
                .foregroundStyle(Color(.blue30).gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", dailyStat.date.parsedDate),
                    y: .value("ProductivityNum", dailyStat.animate ? dailyStat.productivityNum : 0)
                )
                .foregroundStyle(Color(.blue30).opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine().foregroundStyle(.gray50)
                AxisTick().foregroundStyle(.gray50)
                AxisValueLabel(format: .dateTime.day()).foregroundStyle(.gray50)
            }
        }
        .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: viewModel.graphData.first?.date.parsedDate ?? Date().koreanDate, upper: viewModel.graphData.last?.date.parsedDate ?? Date().koreanDate))) 
        .chartYScale(domain: -1...(max + 2))
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(.gray50)
                AxisTick().foregroundStyle(.gray50)
                AxisValueLabel()
                    .foregroundStyle(.gray50)  // Y 축 레이블 텍스트 색상을 .gray50으로 설정
            }
        }
        .frame(height: 250)
    }
}
