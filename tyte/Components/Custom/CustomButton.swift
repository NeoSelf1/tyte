/// 로딩 상태를 지원하는 커스텀 버튼 컴포넌트
///
/// 로딩 상태 표시, 비활성화 상태, 그리고 커스텀 스타일을 지원하는
/// 재사용 가능한 버튼 컴포넌트입니다.
///
/// - Parameters:
///   - action: 버튼 탭 시 실행될 클로저
///   - isLoading: 로딩 상태 여부
///   - text: 버튼에 표시될 텍스트
///   - isDisabled: 비활성화 상태 여부
///   - loadingTint: 로딩 인디케이터 색상 (기본값: .gray60)
///   - enabledBackgroundColor: 활성화 상태 배경색 (기본값: .blue30)
///   - disabledBackgroundColor: 비활성화 상태 배경색 (기본값: .gray20)
///   - enabledForegroundColor: 활성화 상태 텍스트색 (기본값: .gray00)
///   - disabledForegroundColor: 비활성화 상태 텍스트색 (기본값: .gray60)
///   - font: 버튼 텍스트 폰트 (기본값: ._body2)
///   - cornerRadius: 모서리 둥글기 (기본값: 10)
///
/// - Note: 주로 로그인, 회원가입 등 폼 제출 버튼으로 사용됩니다.
///
/// ```swift
/// CustomButton(
///     action: viewModel.login,
///     isLoading: viewModel.isLoading,
///     text: "로그인",
///     isDisabled: viewModel.isLoginDisabled
/// )
/// ```
import SwiftUI

struct CustomButton: View {
    let action: () -> Void
    let isLoading: Bool
    let text: String
    let isDisabled: Bool
    var loadingTint: Color = .gray60
    var enabledBackgroundColor: Color = .blue30
    var disabledBackgroundColor: Color = .gray20
    var enabledForegroundColor: Color = .gray00
    var disabledForegroundColor: Color = .gray60
    var font: Font = ._body2
    var cornerRadius: CGFloat = 10
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .tint(loadingTint)
                    .frame(height:56)
            } else {
                Text(text)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(font)
                    .frame(height:56)
                    .background(isDisabled ? disabledBackgroundColor : enabledBackgroundColor)
                    .foregroundColor(isDisabled ? disabledForegroundColor : enabledForegroundColor)
                    .cornerRadius(cornerRadius)
            }
        }
        .disabled(isDisabled || isLoading)
    }
}
