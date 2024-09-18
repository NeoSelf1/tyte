import SwiftUI

struct TagEditBottomSheet: View {
    @Binding var tag: Tag
    let colors: [String]
    let onUpdate: (Tag) -> Void
    let onDelete: (String) -> Void
    
    @State private var editedName: String
    @State private var editedColor: String
    @State private var isColorPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init(tag: Binding<Tag>, colors: [String], onUpdate: @escaping (Tag) -> Void, onDelete: @escaping (String) -> Void) {
        self._tag = tag
        self.colors = colors
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        
        _editedName = State(initialValue: tag.wrappedValue.name)
        _editedColor = State(initialValue: tag.wrappedValue.color)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("태그 편집")
                .font(._headline2)
                .foregroundColor(.gray90)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("이름")
                    .font(._body3)
                    .foregroundColor(.gray60)
                
                TextField("태그 이름", text: $editedName)
                    .padding()
                    .background(.gray10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.blue10, lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("색상")
                    .font(._body3)
                    .foregroundColor(.gray60)
                
                Button(action: {
                    isColorPickerPresented = true
                }) {
                    HStack {
                        Circle()
                            .fill(Color(hex: "#\(editedColor)"))
                            .frame(width: 24, height: 24)
                        Text("색상 선택")
                            .foregroundColor(.gray90)
                    }
                    .padding()
                    .background(.gray10)
                    .cornerRadius(8)
                }
            }
            
            HStack {
                Button(action: {
                    onDelete(tag.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("삭제하기")
                        .font(._title)
                        .padding()
                        .background(.gray20)
                        .foregroundStyle(.gray60)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onUpdate(Tag(id: tag.id, name:editedName, color: editedColor, user: tag.user))
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("변경하기")
                        .frame(maxWidth: .infinity)
                        .font(._title)
                        .padding()
                        .background(.blue30)
                        .foregroundStyle(.gray00)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(.gray00)
        .sheet(isPresented: $isColorPickerPresented) {
            ColorPickerBottomSheet(selectedColor: $editedColor, colors: colors)
                .presentationDetents([.height(240)])
        }
        .environment(\.colorScheme, .light)
    }
}
