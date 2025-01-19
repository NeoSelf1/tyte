import SwiftUI

/// 앱의 팝업 표시를 관리하는 싱글톤 클래스
///
/// 다양한 유형의 팝업을 표시하고 관리합니다.
/// 애니메이션이 적용된 모달 형태의 팝업을 제공합니다.
///
/// - Note: 필수 액션이 있는 팝업의 경우 배경 탭으로 닫을 수 없습니다.
/// - Important: 팝업은 한 번에 하나만 표시될 수 있습니다.
final class PopupManager: ObservableObject {
    static let shared = PopupManager()
    
    private init() {}
    
    @Published var popupPresented = false
    
    private(set) var currentPopupData: PopupData?
    
    func show(type: PopupType, action: @escaping () -> Void) {
        currentPopupData = PopupData(type: type, action: action)
        popupPresented = true
    }
}

struct PopupViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    let data: PopupData?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented, let popupData = data {
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                            .opacity(isAnimating ? 0.3 : 0.0)
                            .onTapGesture {
                                if !popupData.type.isMandatory { dismissPopup() }
                            }
                            .animation(.spring(duration: 0.1), value: isAnimating)
                        
                        CustomPopup(
                            hidePopup: dismissPopup,
                            popupData: popupData
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -80)
                        .animation(.spring(duration: 0.3), value: isAnimating)
                    }
                }
            }
            .onChange(of: isPresented) { _, newValue in
                isAnimating = newValue
            }
    }
    
    private func dismissPopup() {
        isPresented = false
        isAnimating = false
    }
}
