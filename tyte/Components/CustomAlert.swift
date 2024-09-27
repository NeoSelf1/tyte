import SwiftUI

struct CustomAlert: View {
    @Binding var isShowing: Bool
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(._headline2)
                    .foregroundColor(.gray90)
                    .padding(.top,12)
                
                Text(message)
                    .font(._body3)
                    .foregroundColor(.gray50)
                    .multilineTextAlignment(.center)
                
                Spacer().frame(height:12)
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            isShowing = false
                            secondaryAction()
                        }
                    }) {
                        Text(secondaryButtonTitle)
                            .frame(maxWidth: .infinity)
                            .font(._body1)
                            .padding()
                            .background(.gray20)
                            .foregroundColor(.gray60)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                            primaryAction()
                        }
                    }) {
                        Text(primaryButtonTitle)
                            .frame(maxWidth: .infinity)
                            .font(._body1)
                            .padding()
                            .background(Color.blue30)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(.gray00)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }
}
