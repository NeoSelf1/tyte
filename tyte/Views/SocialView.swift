import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel = SocialViewModel()
    
    var body: some View {
        VStack{
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
                
                NavigationLink(destination: FriendRequestsView(viewModel: viewModel)) {
                    ZStack{
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
                
                NavigationLink(destination: FriendSearchView(viewModel: viewModel)) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray90)
                        .padding(12)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth:.infinity,maxHeight: 56,alignment: .trailing)
            
            CalenderView(
                currentMonth: $viewModel.currentMonth,
                dailyStats: viewModel.friendDailyStats,
                selectDateForInsightData:{ date in
                    viewModel.selectDate(date: date)
                }
            )
            
            Spacer()
        }
        .background(.gray10)
        .sheet(isPresented: $viewModel.isDetailViewPresented) {
            DetailView(todosForDate: viewModel.todosForDate,
                       dailyStatForDate: viewModel.dailyStatForDate,
                       isLoading: viewModel.isLoading
            )
            .presentationDetents([.height(640), .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview{
    SocialView()
}
