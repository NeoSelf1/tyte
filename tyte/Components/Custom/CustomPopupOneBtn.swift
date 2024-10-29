import SwiftUI

struct CustomPopupOneBtn: View {
    @Binding var isShowing: Bool
    
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing:0){
                Button(action: {
                    withAnimation { isShowing = false }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
                
                Text(title)
                    .font(._headline2)
                    .foregroundColor(.gray90)
                    .padding(.top, -16)
                    .padding(.bottom, 6)
                
                Text(message)
                    .font(._body3)
                    .foregroundColor(.gray50)
                    .multilineTextAlignment(.center)
                
                Spacer().frame(height:20)
                
                Button(action: {
                    primaryAction()
                    withAnimation { isShowing = false }
                    
                }) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .font(._title)
                        .padding()
                        .background(isDisabled ? .gray50 : .blue30)
                        .foregroundStyle(isDisabled ? .gray60 : .gray00)
                        .cornerRadius(8)
                }
                .disabled(isDisabled)
                
                
            }
            .padding(12)
            .background{
                RoundedRectangle(cornerRadius: 16).fill(.gray00)
                    .shadow(radius: 10)
            }
            .padding(.horizontal, 40)
        }
    }
}
