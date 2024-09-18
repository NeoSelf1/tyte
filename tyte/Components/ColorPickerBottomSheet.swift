import SwiftUI

struct ColorPickerBottomSheet: View {
    @Binding var selectedColor: String
    let colors: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("색상 선택")
                .font(._headline2)
                .foregroundColor(.gray90)
                .frame(maxWidth: .infinity,alignment: .topLeading)
                .padding()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(colors, id: \.self) { colorHex in
                    Button(action: {
                        selectedColor = colorHex
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Rectangle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
            .background(.gray10)
            .environment(\.colorScheme, .light)
        }
    }
}
