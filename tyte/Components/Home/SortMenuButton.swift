//
//  SortMenuButton.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct SortMenuButton: View {
    @EnvironmentObject var viewModel : TodoListViewModel
    
    @Binding var sortOption: String
    
    var body: some View {Menu {
        Button("마감 임박") {
            sortOption = "마감 임박순"
            viewModel.fetchTodos(mode: "default")
        }
        
        Button("최근 추가") {
            sortOption = "최근 추가순"
            viewModel.fetchTodos(mode: "recent")
        }
        
        Button("중요도") {
            sortOption = "중요도순"
            viewModel.fetchTodos(mode: "important")
        }
    } label: {
        
        HStack(spacing:8) {
            Text(sortOption)
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
