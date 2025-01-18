/// 앱 내 알림을 표시하는 토스트 컴포넌트
///
/// 아이콘, 메시지, 그리고 선택적 액션 버튼을 포함하는 토스트 알림을 표시합니다.
/// 상단에 일시적으로 표시되며 자동으로 사라집니다.
///
/// - Parameters:
///   - toastData: 토스트에 표시할 데이터와 액션을 포함하는 `ToastData` 객체
///
/// - Note: ToastManager에 의해 관리되며, 앱 전역에서 사용됩니다.
///
/// ```swift
/// ToastManager.shared.show(.error("네트워크 오류가 발생했습니다."))
/// ```
import SwiftUI
import Foundation

struct CustomToast: View {
    let toastData: ToastData
    
    var body: some View {
        HStack (spacing:8){
            Image(systemName: toastData.type.icon)
                .font(._subhead1)
                .foregroundStyle(.blue30)
            
            Text(toastData.type.text)
                .font(._subhead2)
                .frame(maxWidth: .infinity,alignment: .leading)
            
            if let action = toastData.action {
                Button(action: action ) {
                    Text(toastData.type.button ?? "보기")
                        .font(._body4)
                        .foregroundStyle(.gray60)
                }
                .padding(.horizontal,6)
            }
        }
        .frame(width: 300,alignment: .leading)
        .padding()
        .background(.gray10)
        .foregroundColor(.gray60)
        .cornerRadius(8)
        .shadow(color: .gray60.opacity(0.2), radius: 16)
    }
}
