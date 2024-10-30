//
//  FriendRequestsView.swift
//  tyte
//
//  Created by Neoself on 10/29/24.
//
import SwiftUI

struct FriendRequestsView: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss  // SwiftUI의 dismiss 환경 값 추가
    @State private var selectedRequest: FriendRequest?
    @State private var showAcceptPopup = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.pendingRequests.isEmpty {
                    Text("받은 친구 요청이 없습니다")
                        .font(._body1)
                        .foregroundStyle(.gray50)
                } else {
                    List(viewModel.pendingRequests) { request in
                        FriendRequestRow(request: request)
                            .onTapGesture {
                                selectedRequest = request
                                showAcceptPopup = true
                            }
                    }
                    .refreshable {
                        viewModel.fetchPendingRequests()
                    }
                }
            }
            .overlay {
                if showAcceptPopup {
                    CustomPopupOneBtn(
                        isShowing: $showAcceptPopup,
                        title: selectedRequest?.fromUser.username ?? "",
                        message: "친구 요청을 수락하시겠습니까?",
                        primaryButtonTitle: "수락하기",
                        primaryAction: {
                            if let request = selectedRequest {
                                viewModel.acceptFriendRequest(request)
                            }
                        },
                        isDisabled: false
                    )
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

struct FriendRequestRow: View {
    let request: FriendRequest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(request.fromUser.username)
                    .font(._subhead1)
                Text(request.fromUser.email)
                    .font(._caption)
                    .foregroundStyle(.gray50)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
