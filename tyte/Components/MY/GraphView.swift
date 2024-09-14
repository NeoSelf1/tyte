import SwiftUI
import Charts

struct GraphView: View {
    // MARK: 1. 환경객체로 TodoListViewModel을 사용하고 있기에, GraphView는 해당 모델의 변경사항을 관찰하고 있음
    // 즉, Model 내부 Published 변수가 변경될 경우, Graphview 무효화 및 다시 그림 = body 프로퍼티 재평가
    @EnvironmentObject var viewModel: MyPageViewModel
    // MARK: @State 프로토콜 변수가 변경되면 뷰를 다시 그림.
    @State var currentTab: String = "week"
    
    @State var currentActiveItem: DailyStatForGraph?
    @State var plotWidth: CGFloat = 0
    @State var isLineGraph: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                // MARK: New Chart API
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Text("생산지수")
                            .fontWeight(.semibold)
                        
                        Picker("", selection: $currentTab) {
                            Text("주간")
                                .tag("week")
                            Text("월간")
                                .tag("month")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading,80)
                    }
                    AnimatedChart()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            // MARK: Simply Updating Values For Segmented Tabs
            .onChange(of: currentTab) { (oldValue, newValue) in
                viewModel.animateGraph(fromChange: true)
            }
            .onAppear {
                print("onAppear")
                viewModel.animateGraph()
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {
        let max:Int = Int(viewModel.graphData.max { item1, item2 in
            return item2.productivityNum > item1.productivityNum
        }?.productivityNum ?? 0)
        
        Chart {
            ForEach(viewModel.graphData){dailyStat in
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
                .foregroundStyle(Color(.blue30).opacity(0.2).gradient)
                .interpolationMethod(.catmullRom)
                
                
                // MARK: Rule Mark For Currently Dragging Item 버그
                //                if let currentActiveItem,currentActiveItem.date == dailyStat.date {
                //                    RuleMark(x: .value("Date", currentActiveItem.date))
                //                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                //                        .annotation(position: .top) {
                //                            VStack(alignment: .leading, spacing: 6) {
                //                                Text("\(currentActiveItem.date.apiFormat)의 생산지수")
                //                                    .font(.caption)
                //                                    .foregroundColor(.gray)
                //
                //                                Text("\(currentActiveItem.productivityNum)")
                //                                    .font(.title3.bold())
                //                            }
                //                            .padding(.horizontal, 10)
                //                            .padding(.vertical, 4)
                //                            .background {
                //                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                //                                    .fill((Color.white).shadow(.drop(radius: 2)))
                //                            }
                //                        }
                //                }
            }
        }
        .chartXAxis {
            // 날짜에 대한 점선 렌더링 로직
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day())
            }
        }
        .chartYScale(domain: 0...(max + 20))
        .chartOverlay { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    if let currentItem = viewModel.graphData.first(where: { item in
                                        Calendar.current.isDate(item.date.parsedDate, inSameDayAs: date)
                                    }) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotSize.width
                                    }
                                }
                            }.onEnded { _ in
                                self.currentActiveItem = nil
                            }
                    )
            }
        }
        .frame(height: 250)
    }
}

#Preview{
        GraphView()
        .environmentObject(MyPageViewModel())
}
