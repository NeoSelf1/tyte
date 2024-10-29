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
            .navigationTitle("받은 친구 요청")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray60)
                        .padding(8)
                }
            )
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
        .presentationDragIndicator(.visible)  // 상단에 드래그 인디케이터 표시
        .interactiveDismissDisabled(showAcceptPopup)  // 팝업이 표시중일 때는 dismiss 불가능하게 설정
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
