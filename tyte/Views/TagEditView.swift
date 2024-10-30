import SwiftUI

struct TagEditView: View {
    @StateObject var viewModel = TagEditViewModel()
    @Environment(\.dismiss) var dismiss
    private var shouldPresentSheet: Binding<Bool> {
        Binding(
            get: { viewModel.isEditBottomPresented && viewModel.selectedTag != nil },
            set: { viewModel.isEditBottomPresented = $0 }
        )
    }
    let defaultTagNames = ["학습","여가","건강"]
    
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
                    text: $viewModel.tagInput,
                    placeholder: "태그 제목",
                    keyboardType: .default,
                    onSubmit: { !viewModel.tagInput.isEmpty ? viewModel.addTag() : print("isEmpty") }
                )
                .submitLabel(.done)
                
                Button(action: {
                    viewModel.isColorPickerPresented = true
                }) {
                    Circle().fill(Color(hex:"#\(viewModel.selectedColor)")).frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal,16)
            .padding(.bottom,16)
            .background(.gray00)
            
            List {
                specialTagView(Tag(id: "dummy_1", name: "학습", color: "FF0000", user: "dummyUser"))
                specialTagView(Tag(id: "dummy_2", name: "여가", color: "F0E68C", user: "dummyUser"))
                specialTagView(Tag(id: "dummy_3", name: "건강", color: "00FFFF", user: "dummyUser"))
                
                ForEach(viewModel.tags.filter{!defaultTagNames.contains($0.name)}) { tag in
                    regularTagView(tag)
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .refreshable(action: {viewModel.fetchTags()})
            .padding(.horizontal)
            .background(.gray10)
        }
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .sheet(isPresented: $viewModel.isColorPickerPresented) {
            ColorPickerBottomSheet(selectedColor: $viewModel.selectedColor)
                .presentationDetents([.height(360)])
                .presentationBackground(.gray00)
        }
        .sheet(isPresented: shouldPresentSheet, content: {
            if let tag = viewModel.selectedTag {
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
        .alert(isPresented: $viewModel.isDuplicateWarningPresent) {
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray20)
        )
        
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .padding(.top,16)
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray00)
                .stroke(.gray30, lineWidth: 1)
                .padding(1)
        )
        .padding(.top,16)
        
        .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
        .listRowSeparator(.hidden) // 사이 선
        .listRowBackground(Color.clear)
        
        .onTapGesture {
            viewModel.selectedTag = tag
            viewModel.isEditBottomPresented = true
        }
    }
    
}

#Preview{
    TagEditView(viewModel: TagEditViewModel())
}
