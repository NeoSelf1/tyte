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
            HStack {
                Text("색상 선택")
                    .font(._headline2)
                    .foregroundColor(.gray90)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray60)
                        .font(._headline2)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                ForEach(colors, id: \.self) { colorHex in
                    Button(action: {
                        withAnimation { selectedColor = colorHex }
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
                    withAnimation { selectedColor = customColor.toHex() }
                    dismiss()
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
    }
}
