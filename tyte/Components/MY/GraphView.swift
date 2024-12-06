import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var viewModel : MyPageViewModel
    
    var body: some View {
        VStack(alignment:.leading, spacing:0){
            VStack(alignment:.leading){
                let totalProductivityNum = Double(viewModel.graphData.reduce(0) {$0 + $1.productivityNum})
                Text(String(totalProductivityNum))
                    .font(._headline2)
                    .foregroundStyle(.gray90)
                    .contentTransition(.numericText(value: totalProductivityNum))
                    .animation(.snappy, value: totalProductivityNum)
                
                Text("총 생산지수")
                    .font(._body3)
                    .foregroundStyle(.gray50)
            }
            .padding(.leading,24)
            
            if (viewModel.graphData.isEmpty){
                Text("데이터가 없어요!")
                    .font(._body3)
                    .foregroundStyle(.gray50)
                    .frame(maxWidth: .infinity, maxHeight: 240, alignment: .center)
            } else {
                LineGraph()
                    .id("chart")
                    .frame(maxWidth: .infinity, maxHeight:240)
                    .padding(16)
            }
        }
    }
    
    @ViewBuilder
    func LineGraph()->some View {
        let max:Int = Int(viewModel.graphData.max { item1, item2 in
            return item2.productivityNum > item1.productivityNum
        }?.productivityNum ?? 0)
        let lastDay = Int(String(viewModel.graphData.last?.date.suffix(2) ?? "30")) ?? 30

        Chart {
            ForEach(viewModel.graphData){ dailyStat in
                let day = Int(dailyStat.date.suffix(2)) ?? 1
                
                LineMark(
                    x: .value("Date", day),
                    y: .value("ProductivityNum", viewModel.isGraphPresent ? dailyStat.productivityNum : 0)
                )
                .foregroundStyle(Color(.blue30).gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", day),
                    y: .value("ProductivityNum", viewModel.isGraphPresent ? dailyStat.productivityNum : 0)
                )
                .foregroundStyle(Color(.blue30).opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                if let day = value.as(Int.self) {
                    if day % 5 == 0 {
                        AxisGridLine(centered: true, stroke: .init(lineWidth:1))
                            .foregroundStyle(.gray90)
                        
                        AxisValueLabel {
                            Text("\(day)일")
                                .font(._caption)
                                .foregroundStyle(.gray)
                                .frame(width:32)
                                .offset(x:-16)
                        }
                    } else {
                        AxisGridLine()
                            .foregroundStyle(.gray50)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine().foregroundStyle(.gray)
                AxisValueLabel()
                    .font(._caption)
                    .foregroundStyle(.gray90)
            }
        }
        .chartXScale(domain: 1...lastDay)
        .chartYScale(domain: -1...(max + 2))
    }
}
