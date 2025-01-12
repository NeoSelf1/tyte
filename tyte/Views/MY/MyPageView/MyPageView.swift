import SwiftUI
import Charts

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    
    var body: some View {
        VStack (spacing: 0){
            header
            
            CalendarDateSelector(currentMonth: $viewModel.currentDate)
            
            ZStack {
                if viewModel.isCalendarMode {
                    VStack(spacing:16){
                        guideBox
                        
                        CalendarView(
                            currentMonth: viewModel.currentDate,
                            dailyStats:viewModel.dailyStats,
                            selectDateForInsightData: viewModel.selectCalendarDate
                        )
                    }
                } else {
                    GraphView(viewModel: viewModel)
                }
                
                if viewModel.isLoading { ProgressView() }
            }
            
            Spacer()
        }
        .background(.gray00)
        .sheet(isPresented: $viewModel.isDetailViewPresent) {
            MultiLayerBottomSheet(viewModel: viewModel)
                .presentationDetents([.height(720), .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var guideBox: some View {
        HStack(alignment: .top) {
            Text("기록이 있는 날짜를 선택하면\n상세분석결과를 확인할 수 있어요")
                .font(._body2)
                .foregroundColor(.gray50)
            
            Spacer()
            
            VStack (alignment: .leading,spacing: 0){
                ForEach(viewModel.tags.prefix(4)) { tag in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: tag.color))
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(.gray50))
                        
                        Text(tag.name)
                            .font(._body3)
                            .foregroundColor(.gray60)
                    }
                }
                
                if viewModel.tags.count > 4 {
                    Text("...")
                        .font(._body3)
                        .foregroundColor(.gray60)
                }
            }
        }
        .padding()
        .frame(minHeight:104,alignment: .top)
        .background(.gray10)
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var header: some View {
        HStack (alignment: .center){
            Text("MY")
                .font(._headline2)
                .foregroundStyle(.gray90)
            
            Spacer()
            
            Button(action: { withAnimation { viewModel.toggleMode() } }
            ) {
                ZStack {
                    Circle()
                        .stroke(.blue10, lineWidth: 1)
                        .frame(width:48,height:48)
                    
                    if viewModel.isCalendarMode {
                        Image(systemName: "chart.xyaxis.line")
                            .font(._headline2)
                            .tint(.gray90)
                        
                    } else {
                        Image("calendar")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray90)
                    }
                }
            }
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 24, height:24)
                    .foregroundColor(.gray90)
                    .padding(12)
            }
        }
        .frame(height:56)
        .padding(.horizontal)
    }
}


private struct GraphView: View {
    @ObservedObject var viewModel : MyPageViewModel
    
    var body: some View {
        VStack(alignment:.leading, spacing:0){
            VStack(alignment:.leading){
                let totalProductivityNum = Double(viewModel.graphData.reduce(0) {$0 + $1.productivityNum})
                
                Text(totalProductivityNum.formatted())
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

#if DEBUG
#Preview {
    MyPageView()
}
#endif
