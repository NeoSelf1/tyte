import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @State private var bottomSheetPosition: PresentationDetent = .height(720)
    
    var body: some View {
        VStack (spacing:0){
            header
            
            ZStack{
                if (viewModel.currentTab == 0){
                    VStack(spacing: 12) {
                        HStack{
                            Text("기록이 있는 날짜를 선택하면 상세분석결과를 확인할 수 있어요")
                                .font(._body3)
                                .foregroundColor(.gray50)
                            Spacer()
                        }
                        .padding()
                        .background(.gray10)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        CalenderView(
                            currentMonth: $viewModel.currentDate,
                            dailyStats:viewModel.dailyStats,
                            selectDateForInsightData: viewModel.selectCalendarDate
                        )
                    }
                    .frame(maxHeight: 450)
                    
                } else {
                    GraphView(viewModel: viewModel)
                        .frame(maxHeight: 360)
                        .onAppear{ viewModel.animateGraph() }
                }
                
                if viewModel.isLoading { ProgressView() }
            }
            
            Spacer()
        }
        .background(.gray00)
        .sheet(isPresented: $viewModel.isDetailViewPresent) {
            MultiLayerBottomSheet(viewModel: viewModel, bottomSheetPosition: $bottomSheetPosition)
                .presentationDetents([.height(720), .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var header: some View {
        HStack (alignment: .center){
            ViewSelector(viewModel: viewModel)
            
            Spacer()
                .frame(width:120)
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 24,height:24)
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
        .environmentObject(AppState.shared)
}
