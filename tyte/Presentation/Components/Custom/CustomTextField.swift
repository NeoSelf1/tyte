/// 커스텀 스타일이 적용된 텍스트 입력 필드 컴포넌트
///
/// 제네릭 타입을 사용하여 다양한 데이터 타입의 입력을 지원하며,
/// 플레이스홀더, 키보드 타입, 제출 액션 등을 커스터마이즈할 수 있습니다.
///
/// - Parameters:
///   - text: 입력된 텍스트를 바인딩하는 변수
///   - placeholder: 입력 필드의 플레이스홀더 텍스트
///   - keyboardType: 키보드 타입 (기본값: .default)
///   - onSubmit: 입력 완료 시 실행될 클로저
///   - textColor: 입력 텍스트 색상 (기본값: .gray90)
///   - placeholderColor: 플레이스홀더 색상 (기본값: .gray50)
///   - backgroundColor: 배경 색상 (기본값: .gray10)
///   - borderColor: 테두리 색상 (기본값: .blue10)
///
/// - Note: 로그인, 회원가입, 검색 등 다양한 입력 화면에서 사용됩니다.
///
/// ```swift
/// CustomTextField(
///     text: $email,
///     placeholder: "이메일",
///     keyboardType: .emailAddress
/// )
/// ```
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
