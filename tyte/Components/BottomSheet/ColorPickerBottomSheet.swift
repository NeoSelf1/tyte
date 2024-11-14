import SwiftUI

struct ColorPickerBottomSheet: View {
    @Binding var selectedColor: String
    @Environment(\.dismiss) var dismiss
    @State private var customColor = Color.gray
    @State private var isCustomColorSelected = false
    
    private let colors = [
        "FFF700", "FFA07A", "FF6347", "FF1493", "FF00FF",
        "DA70D6", "9370DB", "8A2BE2", "4169E1", "00CED1"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("색상 선택")
                .font(._headline2)
                .foregroundColor(.gray90)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                ForEach(colors, id: \.self) { colorHex in
                    Button(action: {
                        selectedColor = colorHex
                        dismiss()
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
            
            HStack{
                Text("아래 원을 클릭해 직접 색을 설정할 수 있어요.")
                    .font(._body3)
                    .foregroundColor(.gray50)
                Spacer()
            }
            .padding()
            .background(.gray10)
            .cornerRadius(8)
            
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
                
                Button(action: {
                    selectedColor = customColor.toHex() ?? "#000000"
                    dismiss()
                }) {
                    Text(isCustomColorSelected ? "\(customColor.toHex() ?? "#747474") 색상 선택하기" : "색상 선택되지 않음")
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
        .onChange(of: customColor){ _,newValue in
            isCustomColorSelected = true
        }
    }
}


#Preview {
    ColorPickerBottomSheet(selectedColor: .constant("747474"))
        .frame(height: 360)
        .border(.gray60)
}
