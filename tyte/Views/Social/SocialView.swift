import SwiftUI

enum Route: Hashable {
    case friendRequests
    case searchFriend
}

struct SocialView: View {
    @StateObject private var viewModel = SocialViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            VStack (spacing:0){
                header
                Divider().frame(minHeight:3).background(.gray10)
                    .padding(.bottom,16)
                
                CalendarDateSelector(currentMonth: $viewModel.currentDate)
                
                guideBox
                    .padding(.bottom,16)
                
                ZStack {
                    CalendarView(
                        currentMonth: viewModel.currentDate,
                        dailyStats: viewModel.friendDailyStats,
                        selectDateForInsightData: viewModel.selectCalendarDate
                    )
                    
                    if viewModel.isLoading{ ProgressView() }
                }
                
                Spacer()
            }
            .background(.gray10)

            .sheet(isPresented: $viewModel.isDetailViewPresent) {
                DetailView(todosForDate: viewModel.todosForDate,
                           dailyStatForDate: viewModel.dailyStatForDate,
                           isLoading: viewModel.isLoading
                )
                .presentationDetents([.height(640), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var guideBox: some View {
            Text("기록이 있는 날짜를 선택하면 친구의 활동을 확인할 수 있어요")
                .font(._body3)
                .foregroundColor(.gray50)
                .frame(maxWidth:.infinity,alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(.gray20, lineWidth: 1))
                .padding(.horizontal)
    }
    
    private var header: some View {
        HStack {
            Menu {
                ForEach(viewModel.friends) { friend in
                    Button(action: {
                        viewModel.selectFriend(friend)
                    }) {
                        Text(friend.username)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedFriend?.username ?? "친구 선택")
                        .font(._headline2)
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(.gray90)
            }
            
            Spacer()
            
            Button(action:{
                viewModel.navigationPath.append(Route.friendRequests)
            }){
                ZStack {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray90)
                        .padding(12)
                    
                    if !viewModel.pendingRequests.isEmpty {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                            .padding(12)
                    }
                }
                .frame(maxWidth: 48, maxHeight: 48)
            }
            
            Button(action:{
                viewModel.navigationPath.append(Route.searchFriend)
            }){
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.gray90)
                    .padding(12)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth:.infinity,maxHeight: 56 ,alignment: .trailing)
        .background(.gray00)
            
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .friendRequests:
                FriendRequestsView(viewModel: viewModel)
            default:
                FriendSearchView(viewModel: viewModel)
            }
        }
    }
}

#Preview{
    SocialView()
}
