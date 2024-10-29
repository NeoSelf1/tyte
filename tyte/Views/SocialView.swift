//
//  SocialView.swift
//  tyte
//
//  Created by Neoself on 10/28/24.
//

import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel = SocialViewModel()
    @State private var showFriendRequests = false
    
    var body: some View {
        NavigationStack{
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
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: { showFriendRequests = true }) {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray90)
                            .padding(12)
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
                        viewModel.selectDateForInsightData(date: date)
                    }
                )
                
                Spacer()
            }
            .sheet(isPresented: $showFriendRequests) {
                FriendRequestsView(viewModel: viewModel)
                    .presentationDetents([.large])  // 전체 화면으로 표시
            }
        }
    }
}

#Preview{
    SocialView()
}
