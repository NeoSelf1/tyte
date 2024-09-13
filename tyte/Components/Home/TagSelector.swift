//
//  TagSelector.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct TagSelector: View {
    @EnvironmentObject private var viewModel : TagEditViewModel
    @Binding var selectedTags: [String]
    
    var body: some View {
        ForEach(viewModel.tags) { tag in
            HStack (spacing:8) {
                Circle().fill(Color(hex:"#\(tag.color)")).frame(width:6)
                
                Text(tag.name)
                    .font(selectedTags.contains(tag.id) ? ._subhead1 : ._title)
                    .foregroundColor(.gray90 )
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.blue10)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(selectedTags.contains(tag.id) ? .blue30 : .gray50.opacity(0.0) , lineWidth: 1)
            )
            .padding(1)
            .onTapGesture {
                if let index = selectedTags.firstIndex(of: tag.id){
                    if(selectedTags.count>1){
                        selectedTags.remove(at: index)
                    }
                } else {
                    selectedTags.append(tag.id)
                }
            }
        }
        .onAppear {
            selectedTags = viewModel.tags.map { $0.id }
        }
    }
}
