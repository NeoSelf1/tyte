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
    let colors = [
        "FFF700", "FFA07A", "FF6347", "FF1493", "FF00FF",
        "DA70D6", "9370DB", "8A2BE2", "4169E1", "00CED1"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing:16) {
                TextField("", text: $tagInput, prompt: Text("태그 추가...").foregroundColor(.gray50))
                    .onSubmit {
                        addTag()
                    }
                Spacer()
                
                Button(action: {
                    isColorPickerPresented = true
                }) {
                    Circle().fill(Color(hex:"#\(selectedColor)")).frame(width: 24, height: 24)
                }
                
                Button(action: {
                    addTag()
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
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex:"#\(tag.color)"))
                        .frame(width: 10, height: 10)
                    Text(tag.name)
                        .font(._subhead2)
                        .foregroundColor(.gray90)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    selectedTag = tag
                    isEditBottomSheetPresented = true
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Tag 관리", displayMode: .inline)
        .environment(\.colorScheme, .light)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { presentationMode.wrappedValue.dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .sheet(isPresented: $isColorPickerPresented) {
            ColorPickerBottomSheet(selectedColor: $selectedColor, colors: colors)
                .presentationDetents([.height(300)])
                .presentationBackground(.gray00)
        }
        .sheet(isPresented: shouldPresentSheet, content: {
            if let tag = selectedTag {
                TagEditBottomSheet(
                    tag: Binding(
                        get: { tag },
                        set: { _ in }
                    ),
                    colors: colors,
                    onUpdate: { updatedTag in
                        viewModel.editTodo(updatedTag)
                    },
                    onDelete: { tagId in
                        viewModel.deleteTag(id: tagId)
                    }
                )
                .presentationDetents([.height(320)])
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
