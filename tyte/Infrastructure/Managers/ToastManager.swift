import SwiftUI

/// 앱의 토스트 메시지를 관리하는 싱글톤 클래스
///
/// 다양한 유형의 토스트 메시지를 표시하고 관리합니다.
/// 자동으로 사라지는 애니메이션이 적용된 토스트를 제공합니다.
///
/// - Note: 토스트는 2초 후 자동으로 사라집니다.
/// - Important: 토스트는 한 번에 하나만 표시될 수 있습니다.
final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    private init() {}
    
    @Published var toastPresented = false
    
    private(set) var currentToastData: ToastData?
    
    func show(_ type: ToastType, action: (() -> Void)? = nil) {
        currentToastData = ToastData(type: type, action:action)
        toastPresented = true
    }
}

struct ToastViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    let data: ToastData?
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let data = data, isPresented {
                    CustomToast(toastData: data)
                        .padding(.top, 40)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -80)
                        .animation(.spring(duration: 0.5), value: isAnimating)
                        .onAppear {
                            withAnimation { isAnimating = true }
                            
                            withAnimation(.spring.delay(2)) {
                                isAnimating = false
                                isPresented = false
                                onDismiss?()
                            }
                        }
                }
            }
    }
}
