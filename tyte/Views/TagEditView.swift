import SwiftUI

struct TagEditView: View {
    @ObservedObject var viewModel: SharedTodoViewModel
    
    @State private var tagInput = ""
    @State private var selectedColor: String = "FF0000" // Default red color
    @State private var isColorPickerPresented = false
    @State private var selectedTag: Tag?
    @State private var showingDeleteConfirmation = false
    @State private var tagToDelete: Tag?
    @State private var showingDuplicateWarning = false
    @State private var isEditBottomSheetPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    private var shouldPresentSheet: Binding<Bool> {
        Binding(
            get: { isEditBottomSheetPresented && selectedTag != nil },
            set: { isEditBottomSheetPresented = $0 }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("태그 추가하기")
                .font(._body3)
                .foregroundColor(.gray90)
                .padding(.leading,24)
                .padding(.top,8)
                .frame(maxWidth:.infinity, alignment:.leading)
            
            HStack(alignment: .center,spacing:16) {
                CustomTextField(
                    text: $tagInput,
                    placeholder: "태그 제목",
                    keyboardType: .default,
                    onSubmit: { addTag() }
                )
                .submitLabel(.done)
                
                Button(action: {
                    isColorPickerPresented = true
                }) {
                    Circle().fill(Color(hex:"#\(selectedColor)")).frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal,16)
            .padding(.bottom,16)
            .background(.gray00)
            
            List {
                ForEach(viewModel.tags) { tag in
                    if tag.name == "일" || tag.name == "자유시간" {
                        specialTagView(tag)
                            .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                            .listRowSeparator(.hidden) // 사이 선
                            .listRowBackground(Color.clear)
                            .padding(.top,16)
                    } else {
                        regularTagView(tag)
                            .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                            .listRowSeparator(.hidden) // 사이 선
                            .listRowBackground(Color.clear)
                            .padding(.top,16)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .refreshable(action: {viewModel.fetchTags()})
            .padding()
            .background(.gray10)
        }
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { presentationMode.wrappedValue.dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .sheet(isPresented: $isColorPickerPresented) {
            ColorPickerBottomSheet(selectedColor: $selectedColor)
                .presentationDetents([.height(360)])
                .presentationBackground(.gray00)
        }
        .sheet(isPresented: shouldPresentSheet, content: {
            if let tag = selectedTag {
                TagEditBottomSheet(
                    tag: Binding(
                        get: { tag },
                        set: { _ in }
                    ),
                    onUpdate: { updatedTag in
                        viewModel.editTag(updatedTag)
                    },
                    onDelete: { tagId in
                        viewModel.deleteTag(id: tagId)
                    }
                )
                .presentationDetents([.height(360)])
            }
        })
        .alert(isPresented: $showingDuplicateWarning) {
            Alert(
                title: Text("중복된 태그"),
                message: Text("이미 존재하는 태그입니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            viewModel.fetchTags()
        }
        .background(.gray00)
    }
    
    private func specialTagView(_ tag: Tag) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex:"#\(tag.color)"))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(.gray50))
            Text(tag.name)
                .font(._subhead2)
                .foregroundColor(.gray60)
        }
        .padding()
        .background(.gray20)
        .cornerRadius(8)
    }
    
    private func regularTagView(_ tag: Tag) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex:"#\(tag.color)"))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(.gray50))
            
            Text(tag.name)
                .font(._subhead2)
                .foregroundColor(.gray90)
        }
        .padding()
        .background(.gray00)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray30, lineWidth: 1)
        )
        .onTapGesture {
            selectedTag = tag
            isEditBottomSheetPresented = true
        }
    }
    
    private func addTag() {
        if !tagInput.isEmpty {
            if viewModel.tags.contains(where: { $0.name.lowercased() == tagInput.lowercased() }) {
                showingDuplicateWarning = true
            } else {
                viewModel.addTag(name: tagInput, color: selectedColor)
                tagInput = ""
            }
        }
    }
}

#Preview{
    TagEditView(viewModel: SharedTodoViewModel())
}
