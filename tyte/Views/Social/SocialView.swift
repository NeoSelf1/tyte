import SwiftUI

enum Route: Hashable {
    case friendRequests
    case searchFriend
}

struct SocialView: View {
    @StateObject private var viewModel: SocialViewModel
    
    init(viewModel: SocialViewModel = SocialViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            VStack {
                header
                
                ZStack {
                    CalenderView(
                        currentMonth: $viewModel.currentDate,
                        dailyStats: viewModel.friendDailyStats,
                        selectDateForInsightData: viewModel.selectCalendarDate
                    )
                    if viewModel.isLoading{ ProgressView() }
                }
                Spacer()
            }
            .background(.gray10)
            .onAppear{ viewModel.initialize() }
            
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
