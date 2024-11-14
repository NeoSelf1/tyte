import SwiftUI

struct FriendRequestsView: View {
    @EnvironmentObject var appState :AppState
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: SocialViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.pendingRequests.isEmpty {
                    Text("받은 친구 요청이 없습니다")
                        .font(._body1)
                        .foregroundStyle(.gray50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.pendingRequests) { request in
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text(request.fromUser.username)
                                            .font( ._subhead1 )
                                            .foregroundStyle(.gray90)
                                        Text(request.fromUser.email)
                                            .font(._caption)
                                            .foregroundStyle(.gray50)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .center,spacing: 4){
                                        Text("친구 수락하기")
                                            .font( ._body2 )
                                            .padding(12)
                                            .background{
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(.blue30)
                                            }
                                            .foregroundStyle(.gray00)
                                    }
                                    .onTapGesture {
                                        appState.showPopup(
                                            type: .acceptFriend(username: request.fromUser.username),
                                            action: { viewModel.acceptFriendRequest(request) }
                                        )
                                    }
                                }
                                .background(.clear)
                                .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.fetchPendingRequests()
                    }
                }
            }
            .onAppear{
                viewModel.fetchPendingRequests()
            }
        }
        .navigationBarTitle("받은 친구 요청", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
    }
}
