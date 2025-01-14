/// 사용자 상호작용이 필요한 팝업 다이얼로그 컴포넌트
///
/// 제목, 설명, 그리고 하나 또는 두 개의 액션 버튼을 포함하는 모달 팝업을 표시합니다.
/// 필수 액션이나 선택적 액션을 처리하는 데 사용됩니다.
///
/// - Parameters:
///   - hidePopup: 팝업을 닫는 클로저
///   - popupData: 팝업에 표시할 데이터와 액션을 포함하는 `PopupData` 객체
///
/// - Note: PopupManager에 의해 관리되며, 앱 전역에서 사용됩니다.
///
/// ```swift
/// PopupManager.shared.show(
///     type: .loginRequired,
///     action: { appState.isGuestMode = false }
/// )
/// ```
import SwiftUI

struct CustomPopup: View {
    let hidePopup: () -> Void
    let popupData: PopupData
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing:6){
                Text(popupData.type.title)
                    .font(._headline2)
                    .foregroundColor(.gray90)
                    .padding(.top,4)
                
                Text(popupData.type.description)
                    .font(._body3)
                    .foregroundColor(.gray50)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,12)
            
            if popupData.type.isMandatory {
                Button(action: {
                    popupData.action()
                }) {
                    Text(popupData.type.primaryButtonText)
                        .frame(maxWidth: .infinity)
                        .font(._body1)
                        .padding(.vertical, 9)
                        .foregroundStyle(.gray00)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(.blue30)
                        )
                }
                .padding(8)
            } else{
                if popupData.type.isBtnHorizontal {
                    horizontalButtonLayer
                } else {
                    verticalButtonLayer
                }
            }
        }
        .padding(.horizontal,12)
        .padding(.vertical,8)
        .background(RoundedRectangle(cornerRadius:20)
            .fill(.gray00)
        )
        .padding(.horizontal, 44)
    }
    
    
    // MARK: - 하단 버튼 레이어
    private var verticalButtonLayer: some View {
        VStack(spacing: 4) {
            Button(action: {
                popupData.action()
                hidePopup()
            }) {
                Text(popupData.type.primaryButtonText)
                    .frame(maxWidth: .infinity)
                    .font(._body1)
                    .padding(.vertical, 9)
                    .foregroundStyle(.gray00)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(.blue30)
                    )
            }
            
            Button(action: {
                hidePopup()
            }) {
                Text("닫기")
                    .font(._body1)
                    .foregroundStyle(.gray60)
            }
            .padding(8)
        }
    }
    
    private var horizontalButtonLayer: some View {
        HStack(spacing: 8) {
            Button(action: {
                hidePopup()
            }) {
                Text(popupData.type.secondaryButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.gray20)
                    .foregroundColor(.gray60)
                    .cornerRadius(8)
            }
            
            Button(action: {
                popupData.action()
                hidePopup()
            }) {
                Text(popupData.type.primaryButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.blue30)
                    .foregroundStyle(.gray00)
                    .cornerRadius(8)
            }
        }
        .font(._body1)
    }
}
