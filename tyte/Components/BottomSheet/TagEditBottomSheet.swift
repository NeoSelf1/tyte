import SwiftUI

struct TagEditBottomSheet: View {
    @Binding var tag: Tag
    let onUpdate: (Tag) -> Void
    let onDelete: (String) -> Void
    
    @State private var editedName: String
    @State private var editedColor: String
    @State var customColor = Color.gray
    
    @State var isCustomColorSelected = false
    @State private var showingColorPicker = false
    
    @Environment(\.dismiss) var dismiss
    
    init(tag: Binding<Tag>, onUpdate: @escaping (Tag) -> Void, onDelete: @escaping (String) -> Void) {
        self._tag = tag
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        
        _editedName = State(initialValue: tag.wrappedValue.name)
        _editedColor = State(initialValue: tag.wrappedValue.color)
    }
    
    var body: some View {
        if showingColorPicker {
            colorPickerView
        } else {
            editView
        }
    }
    
    private var editView: some View {
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
                    withAnimation(.mediumFastEaseInOut) { showingColorPicker = true }
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
                    dismiss()
                }) {
                    Text("삭제하기")
                        .font(._title)
                        .padding()
                        .background(.gray20)
                        .foregroundStyle(.gray60)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onUpdate(Tag(id: tag.id, name: editedName, color: editedColor, user: tag.user))
                    dismiss()
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
        .transition(.move(edge: .leading))
    }
    
    private var colorPickerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation(.mediumFastEaseInOut) { showingColorPicker = false }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray90)
                }
                
                Text("색상 선택")
                    .font(._headline2)
                    .foregroundColor(.gray90)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            let colors = [
                "FFF700", "FFA07A", "FF6347", "FF1493", "FF00FF",
                "DA70D6", "9370DB", "8A2BE2", "4169E1", "00CED1"
            ]
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                ForEach(colors, id: \.self) { colorHex in
                    Button(action: {
                        editedColor = colorHex
                        withAnimation(.mediumFastEaseInOut) { showingColorPicker = false }
                    }) {
                        Rectangle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray30, lineWidth: 1)
                            )
                    }
                }
            }
            
            Divider()
            
            HStack {
                ColorPicker("", selection: $customColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 120, height: 44)
                    .background(.gray00)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray30, lineWidth: 1)
                    )
                    .onChange(of: customColor){ isCustomColorSelected = true }
                
                Button(action: {
                    editedColor = customColor.toHex()
                    withAnimation(.mediumFastEaseInOut) { showingColorPicker = false }
                }) {
                    Text(isCustomColorSelected ?
                         "\(customColor.toHex()) 색상 선택하기" : "색상 선택되지 않음"
                    )
                    .font(._body2)
                    .foregroundColor(isCustomColorSelected ? .gray00 : .gray50)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isCustomColorSelected ? .blue30 : .gray30)
                    .cornerRadius(8)
                }
                .disabled(!isCustomColorSelected)
            }
        }
        .padding()
        .background(Color.gray00)
        .transition(.move(edge: .trailing))
    }
}
