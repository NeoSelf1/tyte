import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    
    private var uniqueTagStats: [TagStat] {
        viewModel.dailyStats.flatMap{$0.tagStats}.reduce(into: [TagStat]()) { result, tagStat in
            if !result.contains(where: { $0.tag.name == tagStat.tag.name }) {
                result.append(tagStat)
            }
        }
    }
    
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
                ForEach(Array(uniqueTagStats.prefix(4)), id: \.tag.name) { tagStat in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: tagStat.tag.color))
                            .frame(width: 6, height: 6)
                            .overlay(Circle().stroke(.gray50))
                        
                        Text(tagStat.tag.name)
                            .font(._body3)
                            .foregroundColor(.gray60)
                    }
                }
                
                if uniqueTagStats.count > 4 {
                    Text("...")
                        .font(._body3)
                        .foregroundColor(.gray60)
                }
            }
        }
        .padding()
        .frame(minHeight:80,alignment: .top)
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
                            .resizable()
                            .frame(width: 24, height: 24)
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

#Preview {
    MyPageView()
}
