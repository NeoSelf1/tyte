import SwiftUI

/// 오프라인 상태 UI를 관리하는 싱글톤 클래스
///
/// 네트워크 연결 상태에 따라 오프라인 상태 표시를 관리합니다.
/// 애니메이션이 적용된 네트워크 상태 아이콘을 표시합니다.
///
/// - Note: NetworkManager와 연동하여 네트워크 상태 변화를 실시간으로 반영합니다.
final class OfflineUIManager: ObservableObject {
    static let shared = OfflineUIManager()
    
    private init() {}
    
    @Published var offlineUIPresented: Bool = false
    
    func show() {
        offlineUIPresented = true
    }
    
    func hide() {
        offlineUIPresented = false
    }
}

struct OfflineUIViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomLeading) {
                if isPresented {
                    Image(systemName: "network.slash")
                        .resizable()
                        .frame(width: 24,height:24)
                        .foregroundColor(.red)
                        .padding(.leading, 24)
                        .padding(.bottom, 112)
                        .opacity(isAnimating ? 1 : 0.6)
                        .animation(
                            .longEaseInOut
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            withAnimation { isAnimating = true }
                        }
                }
            }
    }
}
