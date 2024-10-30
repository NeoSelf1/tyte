import SwiftUI
import Foundation

struct FriendSearchView: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss  // SwiftUI의 dismiss 환경 값 추가
    @State private var isSearching = false
    
    var body: some View {
            VStack {
                SearchBar(
                    text: $viewModel.searchText,
                    isSearching: $isSearching
                )
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 12) {
                        if viewModel.searchText.isEmpty {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray30)
                            
                            Text("친구를 검색해보세요")
                                .font(._body1)
                                .foregroundColor(.gray50)
                            
                            Text("이메일이나 닉네임으로\n친구를 찾을 수 있어요")
                                .font(._caption)
                                .foregroundColor(.gray30)
                                .multilineTextAlignment(.center)
                        } else {
                            Image(systemName: "person.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray30)
                            
                            Text("검색 결과가 없습니다")
                                .font(._body1)
                                .foregroundColor(.gray50)
                            
                            Text("다른 검색어로 다시 시도해보세요")
                                .font(._caption)
                                .foregroundColor(.gray30)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.searchResults) { searchedUser in
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text(searchedUser.username)
                                            .font( ._subhead1 )
                                            .foregroundStyle(.gray90)
                                        
                                        Text(searchedUser.email)
                                            .font(._caption)
                                            .foregroundStyle(.gray50)
                                    }
                                    Spacer()
                                    statusButton(for: searchedUser)
                                }
                                .background(.clear)
                                .onTapGesture {
                                    viewModel.selectUser(searchedUser)
                                }
                                .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }
                        .padding()
                    }
                }
            
        }
        .navigationBarTitle("친구 검색", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
    }
}

struct SearchBar: View {
    @FocusState private var isTodoInputFocused: Bool
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray50)
                
                TextField("친구 이름으로 검색", text: $text)
                    .foregroundColor(.gray90)
                    .focused($isTodoInputFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never) // 자동 대문자화 비활성화
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(.gray50)
                            .opacity(text.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                text = ""
                            }
                        , alignment: .trailing
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(.gray10)
            .cornerRadius(8)
            .onAppear {
                isTodoInputFocused = true
            }
            
            if isSearching {
                Button("취소") {
                    text = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue30)
            }
        }
        .padding(.horizontal)
        .animation(.default, value: isSearching)
    }
}

@ViewBuilder
private func statusButton(for searchedUser: SearchResult) -> some View {
    if searchedUser.isPending {
        HStack(alignment: .center,spacing: 4){
            Text("친구요청중")
                .font( ._body2 )
                .foregroundStyle(.gray50)
        }
    } else {
        if searchedUser.isFriend{
            HStack(alignment: .center,spacing: 4){
                Text("친구")
                    .font( ._body2 )
                    .foregroundStyle(.gray50)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(._body3)
                    .foregroundStyle(.blue30)
            }
        } else {
            HStack(alignment: .center,spacing: 4){
                Text("친구 추가하기")
                    .font( ._body2 )
                    .padding(12)
                    .background{
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray10)
                    }
                    .foregroundStyle(.gray60)
            }
        }
    }
    
}
#Preview{
    FriendSearchView(viewModel: SocialViewModel())
//    struct PreviewWrapper: View {
//        @State var isShowing = true
//        
//        var body: some View {
//            CustomPopupOneBtn(
//                isShowing: $isShowing,
//                title: "닉네임 1",
//                message: false ? "친구 요청중입니다." : "",
//                primaryButtonTitle: "친구 요청하기",
//                primaryAction: {
//                    print("hleeoo")
//                },
//                isDisabled: true
//            )
//        }
//    }
//    
//    return PreviewWrapper()
}
