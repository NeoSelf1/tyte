import SwiftUI
import Foundation

struct FriendSearchView: View {
    @StateObject var viewModel: FriendViewModel = FriendViewModel()
    
    @State private var isSearching = false
    
    var body: some View {
        VStack {
            SearchBar(
                text: $viewModel.searchText,
                isSearching: $isSearching,
                placeholder: "친구 이름으로 검색"
            )
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.searchResults.isEmpty {
                EmptyStateBox()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults) { result in
                            Text(result.username)
                                .font(._body3)
                            Text(result.email)
                                .font(.caption2)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    var placeholder: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray50)
                
                TextField(placeholder, text: $text)
                    .foregroundColor(.gray90)
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


#Preview{
    FriendSearchView()
}
