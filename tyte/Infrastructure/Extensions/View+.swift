import SwiftUI

/// SwiftUI View의 공통 수정자를 제공하는 확장입니다.
///
/// 다음과 같은 커스텀 수정자를 제공합니다:
/// - 토스트 메시지 표시
/// - 팝업 표시
/// - 오프라인 UI 표시
///
/// ## 사용 예시
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         MainView()
///             .presentToast(isPresented: $showToast, data: toastData)
///             .presentPopup(isPresented: $showPopup, data: popupData)
///     }
/// }
/// ```
///
/// ## 관련 타입
/// - ``ToastData``
/// - ``PopupData``
/// - ``OfflineUIManager``
///
/// - Note: 모든 수정자는 앱의 디자인 시스템을 따릅니다.
extension View {
    func presentToast(
        isPresented: Binding<Bool>,
        data: ToastData?,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            ToastViewModifier(
                isPresented: isPresented,
                data: data,
                onDismiss: onDismiss
            )
        )
    }
    
    func presentPopup(
        isPresented: Binding<Bool>,
        data: PopupData?
    ) -> some View {
        modifier(PopupViewModifier(
            isPresented: isPresented,
            data: data
        ))
    }
    
    func presentOfflineUI(
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(OfflineUIViewModifier(
            isPresented: isPresented
        ))
    }
}
