import SwiftUI

struct TagEditView: View {
    @StateObject var viewModel = TagEditViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            ZStack {
                ScrollView {
                    LazyVStack(alignment:.leading, spacing: 16) {
                        specialTagView(Tag(id: "dummy_1", name: "학습", color: "FF0000", user: "dummyUser"))
                        specialTagView(Tag(id: "dummy_2", name: "여가", color: "F0E68C", user: "dummyUser"))
                        specialTagView(Tag(id: "dummy_3", name: "건강", color: "00FFFF", user: "dummyUser"))
                        
                        ForEach(viewModel.tags.filter{!["학습","여가","건강"].contains($0.name)}) { tag in
                            regularTagView(tag)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.gray10)
                .refreshable(action: { viewModel.handleRefresh()} )
                
                if viewModel.isLoading { ProgressView() }
            }
        }
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .background(.gray00)
        
        .sheet(isPresented: $viewModel.isEditBottomPresent, content: {
            if let tag = viewModel.selectedTag {
                TagEditBottomSheet(
                    tag: Binding(get: { tag }, set: { _ in }),
                    onUpdate: { updatedTag in viewModel.editTag(updatedTag) },
                    onDelete: { tagId in viewModel.deleteTag(id: tagId) }
                )
                .presentationDetents([.height(320)])
            }
        } )
        .alert(isPresented: $viewModel.isDuplicateWarningPresent) {
            Alert( title: Text("중복된 태그"), message: Text("이미 존재하는 태그입니다."), dismissButton: .default(Text("확인")) )
        }
        
        
    }
    
    @ViewBuilder
    private var header: some View {
        Text("태그 추가하기")
            .font(._body3)
            .foregroundColor(.gray90)
            .padding(.leading,24)
            .padding(.top,8)
            .frame(maxWidth:.infinity, alignment:.leading)
        
        HStack(alignment: .center,spacing:16) {
            TextField("",
                      text: $viewModel.tagInput,
                      prompt: Text("태그 제목").foregroundColor(.gray50)
            )
            .foregroundColor(.gray90)
            .autocapitalization(.none)
            .submitLabel(.done)
            .onSubmit { viewModel.addTag() }
            
            Button(action: {
                viewModel.isColorPickerPresent = true
            }) {
                Circle().fill(Color(hex:"#\(viewModel.selectedColor)")).frame(width: 24, height: 24)
                    .opacity(viewModel.tagInput.isEmpty ? 0 : 1.0)
            }
            .disabled(viewModel.tagInput.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16).fill(.gray10)
                .stroke(.blue10, lineWidth: 1).padding(1)
        )
        .padding(.horizontal,16)
        .padding(.bottom,16)
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
        .background(RoundedRectangle(cornerRadius: 8).fill(.gray20))
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
        .background(RoundedRectangle(cornerRadius: 8).fill(.gray00)
                .stroke(.gray30, lineWidth: 1).padding(1))
        .onTapGesture {
            viewModel.selectTag(tag)
        }
    }
    
}

#Preview{
    TagEditView(viewModel: TagEditViewModel())
}
