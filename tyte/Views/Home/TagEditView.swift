import SwiftUI

struct TagEditView: View {
    @StateObject var viewModel = TagEditViewModel()
    @FocusState private var isTagInputFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { isTagInputFocused = false }
            
            VStack(alignment: .leading, spacing: 8) {
                header
                
                ScrollView {
                    LazyVStack(alignment:.leading, spacing: 16) {
                        ForEach(viewModel.tags) { tag in
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
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.gray10)
                
                .onTapGesture { isTagInputFocused = false }
                .refreshable(action: { viewModel.handleRefresh()} )
            }
            
            if viewModel.isLoading { ProgressView() }
        }
        .background(.gray00)
        
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .sheet(isPresented: $viewModel.isColorPickerPresent, content: {
            ColorPickerBottomSheet(selectedColor:$viewModel.selectedColor)
                .presentationDetents([.height(280)])
        })
        .sheet(isPresented: $viewModel.isEditBottomPresent, content: {
            if let tag = viewModel.selectedTag {
                TagEditBottomSheet(
                    tag: Binding(get: { tag }, set: { _ in }),
                    onUpdate: { updatedTag in viewModel.editTag(updatedTag) },
                    onDelete: { tagId in viewModel.deleteTag(id: tagId) }
                )
                .presentationDetents([.height(320)])
            }
        })
        .alert(isPresented: $viewModel.isDuplicateWarningPresent) {
            Alert(
                title: Text("중복된 태그"),
                message: Text("이미 존재하는 태그입니다."),
                dismissButton: .default(Text("확인"))
            )
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
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .focused($isTagInputFocused)
            
            .onSubmit { viewModel.addTag() }
            
            if !viewModel.tagInput.isEmpty {
                Button(action: {
                    viewModel.isColorPickerPresent = true
                }) {
                    Circle()
                        .fill(Color(hex:"#\(viewModel.selectedColor)"))
                        .frame(width: 22, height: 22)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16).fill(.gray10)
                .stroke(.blue10, lineWidth: 1).padding(1)
        )
        .padding(.horizontal,16)
        .padding(.bottom,16)
        .background(.gray00)
        
        .animation(.spring(duration:0.2).delay(0.1), value: viewModel.tagInput.isEmpty)
    }
}

#Preview{
    TagEditView(viewModel: TagEditViewModel())
}
