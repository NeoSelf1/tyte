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
            HStack(spacing:4) {
                Image(systemName: "arrow.up.arrow.down")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray60)
                
                Text(viewModel.sortOption.buttonText)
                    .font(._subhead2)
                    .foregroundColor(.gray60)
                
            }
            .padding(.horizontal)
            .padding(.vertical,12)
        }
    }
}
