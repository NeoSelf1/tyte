//
//  SortMenuButton.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct SortMenuButton: View {
    @ObservedObject var viewModel : HomeViewModel
    
    var body: some View {
        Menu {
            Button("마감 임박") {
                viewModel.setSortOption("default")
            }
            
            Button("최근 추가") {
                viewModel.setSortOption("recent")
            }
            
            Button("중요도") {
                viewModel.setSortOption("important")
            }
        } label: {
            HStack(spacing:8) {
                Text(viewModel.sortOption.buttonText)
                    .font(._body4)
                    .foregroundColor(.gray90)
                
                Image(systemName: "arrow.up.arrow.down")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray60)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.gray00)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray50 , lineWidth: 1)
            )
            .shadow(color: .gray90.opacity(0.08), radius: 4)
            .padding(1)
        }
    }
}
