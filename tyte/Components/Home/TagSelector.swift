//
//  TagSelector.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct TagSelector: View {
    @ObservedObject var viewModel : HomeViewModel
    @ObservedObject var sharedVM: SharedTodoViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            // "전체" (All) tag
            TagButton(
                text: "전체",
                color: .blue,
                isSelected: viewModel.isAllTagsSelected,
                action: { viewModel.selectAllTags() }
            )
            
            // "태그없음" (No tag) button
            TagButton(
                text: "태그없음",
                color: Color(hex: "747474"),
                isSelected: viewModel.selectedTags.contains("default"),
                action: { viewModel.toggleTag(id: "default") }
            )
            
            // Other tags
            ForEach(sharedVM.tags) { tag in
                TagButton(
                    text: tag.name,
                    color: Color(hex: "#\(tag.color)"),
                    isSelected: viewModel.selectedTags.contains(tag.id),
                    action: { viewModel.toggleTag(id: tag.id) }
                )
            }
        }
        .padding(.horizontal)
    }
}

struct TagButton: View {
    let text: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 6)
                
                Text(text)
                    .font(._body4)
                    .foregroundStyle(.gray90)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.blue10)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? .blue30 : .gray50.opacity(0.0), lineWidth: 1)
            )
            .padding(1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
