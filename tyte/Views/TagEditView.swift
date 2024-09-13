//
//  TagEditView.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import SwiftUI

struct TagEditView: View {
    @EnvironmentObject var viewModel: TagEditViewModel
    
    @State private var tagInput = ""
    @State private var selectedColor: String = "FF0000" // Default red color
    @State private var isColorPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let colors = [
        "FFF700", "FFA07A", "FF6347", "FF1493", "FF00FF",
        "DA70D6", "9370DB", "8A2BE2", "4169E1", "00CED1"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing:16) {
                TextField("", text: $tagInput,prompt:Text("태그 추가...").foregroundColor(.gray50))
                    .onSubmit {
                        viewModel.addTag(name: tagInput, color: selectedColor)
                        tagInput = ""
                    }
                Spacer()
                
                Button(action: {
                    isColorPickerPresented = true
                }) {
                    Circle().fill(Color(hex:"#\(selectedColor)")).frame(width: 24,height: 24)
                }
                
                Button(action: {
                    viewModel.addTag(name: tagInput, color: selectedColor)
                    tagInput = ""
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                        .frame(height: 32)
                        .foregroundColor(.gray90)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            ForEach(viewModel.tags) { tag in
                HStack(spacing:8) {
                    Circle()
                        .fill(Color(hex:"#\(tag.color)"))
                        .frame(width: 10, height: 10)
                    Text(tag.name)
                        .font(._subhead2)
                        .foregroundColor(.gray90)
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .environment(\.colorScheme, .light)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action:{ presentationMode.wrappedValue.dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .sheet(isPresented: $isColorPickerPresented) {
            ColorPickerBottomSheet(selectedColor: $selectedColor, colors: colors)
                .presentationDetents([.height(240)])
        }
        .onAppear{
            viewModel.fetchTags()
        }
        .background(.gray00)
    }
}

#Preview {
    TagEditView()
}
