import SwiftUI
struct CustomTextField<T>: View where T: Hashable {
    @Binding var text: T
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var onSubmit: (() -> Void)?
    var textColor: Color = .gray90
    var placeholderColor: Color = .gray50
    var backgroundColor: Color = .gray10
    var borderColor: Color = .blue10
    
    var body: some View {
        TextField("",
                  text: Binding(
                    get: { String(describing: text) },
                    set: { if let value = $0 as? T { text = value } }
                  ),
                  prompt: Text(placeholder).foregroundColor(placeholderColor)
        )
        .foregroundColor(textColor)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(backgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .autocapitalization(.none)
        .keyboardType(keyboardType)
        .onSubmit {
            onSubmit?()
        }
    }
}
