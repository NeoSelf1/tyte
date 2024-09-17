import SwiftUI
import Charts

struct GraphView: View {
    @EnvironmentObject var viewModel: MyPageViewModel
    // MARK: @State 프로토콜 변수가 변경되면 뷰를 다시 그림.
    
    @State var plotWidth: CGFloat = 0
    @State private var animationAmount: CGFloat = 1.0
    
    var body: some View {
        // MARK: New Chart API
        VStack(alignment: .leading, spacing:0 ){
            HStack{
                VStack (alignment: .leading){
                    Text("\(viewModel.graphData.reduce(0) {$0 + $1.productivityNum}.formatted())")
                        .font(._headline2)
                        .foregroundStyle(.gray90)
                    
                    Text("총 생산지수")
                        .font(._body3)
                        .foregroundStyle(.gray50)
                }
                Spacer()
                
                Menu {
                    Button("1주") {
                        viewModel.graphRange = "week"
                    }
                    
                    Button("1개월") {
                        viewModel.graphRange = "month"
                    }
                } label: {
                    HStack(spacing:8) {
                        Text(viewModel.graphRange.formattedRange)
                            .font(._body3)
                            .foregroundColor(.gray90)
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 12, height: 8)
                            .foregroundColor(.gray60)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.blue10)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
            
            if (viewModel.graphData.isEmpty){
                Text("데이터가 없어요!")
                    .frame(maxWidth: .infinity, maxHeight: 250, alignment: .center)
                    .padding(.horizontal)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        AnimatedChart()
                            .frame(width: viewModel.zoomInOut())
                            .id("chart")
                            .scaleEffect(animationAmount)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.graphRange)
                            .padding()
                    }
                    .onChange(of: viewModel.graphRange) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.Duration.medium) {
                            withAnimation {
                                proxy.scrollTo("chart", anchor: .trailing)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .onChange(of: viewModel.graphRange) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animationAmount = 0.7
                        plotWidth = viewModel.zoomInOut()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            animationAmount = 1.0
                        }
                    }
                }
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
        .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: viewModel.graphData.first?.date.parsedDate ?? Date(), upper: viewModel.graphData.last?.date.parsedDate ?? Date())))
        .chartYScale(domain: -1...(max + 2))
//        .chartOverlay { proxy in
//            GeometryReader { innerProxy in
//                Rectangle()
//                    .fill(.clear).contentShape(Rectangle())
//                    .gesture(
//                        TapGesture()
//                            .onEnded { location in
//                                if let date: Date = proxy.value(atX: location.x) {
//                                    if let currentItem = viewModel.graphData.first(where: { item in
//                                        Calendar.current.isDate(item.date.parsedDate, inSameDayAs: date)
//                                    }) {
//                                        print(currentItem.date)
//                                        self.currentActiveItem = currentItem
//                                        self.plotWidth = proxy.plotSize.width
//                                    }
//                                }
//                            }
//                    )
//            }
//        }
        .frame(height: 250)
    }
}

#Preview{
        GraphView()
        .environmentObject(MyPageViewModel())
}
