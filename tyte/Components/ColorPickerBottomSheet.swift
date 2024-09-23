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
        }
        .padding()
        .background(.gray00)
    }
}

//#Preview {
//    struct PreviewWrapper: View {
//        @State private var selectedColor = "#FF0000"  // 초기 선택 색상 (예: 빨간색)
//        
//        let colors = [
//            "FFF700", "FFA07A", "FF6347", "FF1493", "FF00FF",
//            "DA70D6", "9370DB", "8A2BE2", "4169E1", "00CED1"
//        ]
//        
//        var body: some View {
//            ColorPickerBottomSheet(selectedColor: $selectedColor, colors: colors)
//                .frame(height: 300)  // 프리뷰 높이 조절
//        }
//    }
//    
//    return PreviewWrapper()
//}
