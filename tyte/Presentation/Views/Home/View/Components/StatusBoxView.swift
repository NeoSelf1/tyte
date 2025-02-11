import SwiftUI

struct StatusBoxView: View {
    @ObservedObject var viewModel: HomeViewModel
    private var dailyStat: DailyStat
    private var balanceData: BalanceData
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        if let index = viewModel.weekCalendarData.firstIndex(where: { viewModel.selectedDate.apiFormat == $0.date }) {
            self.dailyStat = viewModel.weekCalendarData[index]
            self.balanceData = viewModel.weekCalendarData[index].balanceData
        } else {
            self.dailyStat = .empty
            self.balanceData = BalanceData(
                title: "Todo가 없네요 :(",
                message: "아래 + 버튼을 눌러 Todo를 추가해주세요",
                balanceNum: 0
            )
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                circularProgressView(
                    progress: Double(balanceData.balanceNum) / 100.0,
                    color: balanceData.balanceNum.colorByBalanceData
                )
                .frame(width: 64, height: 64)
                
                HStack(spacing: 0) {
                    Text("\(balanceData.balanceNum)")
                        .font(._headline2)
                        .foregroundColor(balanceData.balanceNum.colorByBalanceData)
                        .contentTransition(.numericText(value: Double(balanceData.balanceNum)))
                        .animation(.snappy, value: Double(balanceData.balanceNum))
                    
                    Text("%")
                        .font(._body3)
                        .foregroundColor(balanceData.balanceNum.colorByBalanceData)
                }
            }
            .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(viewModel.selectedDate.formattedDate)
                        .font(._body3)
                        .foregroundStyle(.gray90)
                    
                    Spacer()
                    
                    if dailyStat.date != "emptyData" {
                        NavigationLink(
                            destination: StatisticsView(
                                dailyStat: dailyStat,
                                todos: viewModel.todosForDate
                            )
                        ) {
                            HStack(spacing: 4) {
                                Text("AI분석 보기")
                                    .font(._body3)
                                    .foregroundStyle(.gray60)
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 6, height: 12)
                                    .foregroundStyle(.gray60)
                            }
                        }
                    }
                }
                .padding(.bottom, 4)
                .padding(.trailing, 16)

                
                Text(balanceData.title)
                    .font(._title)
                    .foregroundStyle(.gray90)
                    .padding(.bottom, 2)
                
                Text(balanceData.message)
                    .font(._body3)
                    .foregroundStyle(.gray50)
            }
        }
        .frame(height: 96)
        .background(.gray00)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .gray90.opacity(0.08), radius: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue10, lineWidth: 1)
        )
        .padding(4)
    }
    
    private func circularProgressView(progress: Double, color: Color) -> some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: 3
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.mediumEaseInOut, value: progress)
        }
    }
}
