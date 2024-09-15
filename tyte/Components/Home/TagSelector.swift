//
//  TagSelector.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct TagSelector: View {
    @EnvironmentObject private var viewModel : TagEditViewModel
    
    
    var body: some View {
        HStack (spacing:8) {
            Circle().fill(Color(hex:"747474)")).frame(width:6)
            
            Text("태그없음")
                .font(._body2)
                .foregroundStyle(.gray90)
            
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.blue10)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(viewModel.selectedTags.contains("default") ? .blue30 : .gray50.opacity(0.0) , lineWidth: 1)
        )
        .padding(1)
        .onTapGesture {
            viewModel.toggleTag(id: "default")
        }
        
        ForEach(viewModel.tags) { tag in
            HStack (spacing:8) {
                Circle().fill(Color(hex:"#\(tag.color)")).frame(width:6)
                
                Text(tag.name)
                    .font(._body2)
                    .foregroundStyle(.gray90)
                
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.blue10)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(viewModel.selectedTags.contains(tag.id) ? .blue30 : .gray50.opacity(0.0) , lineWidth: 1)
            )
            .padding(1)
            .onTapGesture {
                viewModel.toggleTag(id:  tag.id)
            }
        }
    }
}
