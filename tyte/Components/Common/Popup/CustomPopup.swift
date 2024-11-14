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
                    .padding(.top,12)
                
                Text(popupData.type.description)
                    .font(._body3)
                    .foregroundColor(.gray50)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,12)
            
            if popupData.type.isBtnHorizontal {
                horizontalButtonLayer
            } else {
                verticalButtonLayer
            }
        }
        .padding(.horizontal,12)
        .padding(.vertical,8)
        .background(RoundedRectangle(cornerRadius:20)
            .fill(.white)
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

//#Preview("Popup") {
//    CustomPopup_Preview()
//}
//
//struct CustomPopup_Preview: View {
//    @State private var showPopup = true
//
//    var body: some View {
//        CustomPopup(isShowing: $showPopup, popupData: PopupData(type:.storeRegister("이대"),action:{print("storeRegister")}))
//        CustomPopup(isShowing: $showPopup, popupData: PopupData(type:.storeDelete("이대"),action:{print("storeDelete")}))
//        CustomPopup(isShowing: $showPopup, popupData: PopupData(type:.login,action:{print("login")}))
//        CustomPopup(isShowing: $showPopup, popupData: PopupData(type:.storeFull,action:{print("storeFull")}))
//    }
//}
