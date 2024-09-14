import SwiftUI
import Charts

struct DailyStatForGraph: Identifiable {
    let id: String  // date를 id로 사용
    let date: String
    let productivityNum: Double
    var animate: Bool = false
    
    init(date: String, productivityNum: Double, animate: Bool = false) {
        self.id = date  // date를 id로 설정
        self.date = date
        self.productivityNum = productivityNum
        self.animate = animate
    }
}

struct GraphView: View {
    // MARK: 1. 환경객체로 TodoListViewModel을 사용하고 있기에, GraphView는 해당 모델의 변경사항을 관찰하고 있음
    // 즉, Model 내부 Published 변수가 변경될 경우, Graphview 무효화 및 다시 그림 = body 프로퍼티 재평가
    @EnvironmentObject var viewModel: TodoListViewModel
    // MARK: @State 프로토콜 변수가 변경되면 뷰를 다시 그림.
    @State var dailyStats: [DailyStatForGraph] = []
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
                    
//                    let totalValue = viewModel.dailyStats.reduce(0.0) { partialResult, item in
//                        item.productivityNum + partialResult
//                    }
                    
//                    Text(totalValue.stringFormat)
//                        .font(.largeTitle.bold())
                    
                    AnimatedChart()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .onAppear{
                // MARK: 2. ListView or HomeView에서 Todo를 변경할 경우 DailyStat이 변경됨에 따라 뷰가 재구성되면서 onAppear이 호출됨.
                print("onAppear")
                updateDateRange()
            }
            // MARK: Simply Updating Values For Segmented Tabs
            .onChange(of: currentTab) { newValue in
                updateDateRange()
            }
        }
    }
    
    func updateDateRange() {
        let calendar = Calendar.current
        let today = Date()
        
        let daysToShow: Int
        switch currentTab {
        case "week":
            daysToShow = 7
        case "month":
            daysToShow = 31
        default:
            daysToShow = 7 
        }
        
        let dateRange = (0..<daysToShow).map { dayOffset in
            calendar.date(byAdding: .day, value: -(daysToShow - 1 - dayOffset), to: today)!
        }
        
        let filteredDailyStats = dateRange.map { date in
            print(date.apiFormat)
            if let existingStat = viewModel.dailyStats.first(where: { $0.date == date.apiFormat }) {
                print("existingStat")
                return DailyStatForGraph(
                    date: existingStat.date,
                    productivityNum: existingStat.productivityNum
                )
            } else {
                print("No Daily")
                return DailyStatForGraph(
                    date: date.apiFormat,
                    productivityNum: 0
                )
            }
        }
        print("updateDateRange")
        // MARK: 3. State 변수인 dailyStats를 함수 내부에서 수정하기 때문에 함수 호출때마다 뷰가 재구성됨. -> 무한반복
        dailyStats = filteredDailyStats
        animateGraph(fromChange: true)
        
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {
        let max:Int = Int(dailyStats.max { item1, item2 in
            return item2.productivityNum > item1.productivityNum
        }?.productivityNum ?? 0)
        
        Chart {
            ForEach(dailyStats){dailyStat in
                // MARK: Bar Graph
                // MARK: Animating Graph
                
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
                                    if let currentItem = dailyStats.first(where: { item in
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
        .onAppear {
            animateGraph()
        }
        .frame(height: 250)
    }
    
    // MARK: Animating Graph
    func animateGraph(fromChange: Bool = false){
        for (index,_) in dailyStats.enumerated(){
            // For Some Reason Delay is Not Working
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ?
                    .easeInOut(duration: 0.6) :
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)
                ){
                    dailyStats[index].animate = true
                }
            }
        }
    }
}

#Preview{
        GraphView()
        .environmentObject(TodoListViewModel())
}
