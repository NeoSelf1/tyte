import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            CustomHeaderWithBackBtn(title: "설정", isDoneHidden: true)
            
            Toggle(isOn: Binding(
                get: { UserDefaultsManager.shared.isDarkMode },
                set: {
                    UserDefaultsManager.shared.setDarkMode($0)
                    setAppearance(isDarkMode: $0)
                }
            )){
                Text("다크모드")
                    .font(._body2)
                    .foregroundColor(.gray90)
            }
            .padding()
            .tint(.blue30)
            .background(Color.gray10)
            .cornerRadius(8)
            
            Divider()
                .padding(.vertical,12)
            
            VStack(spacing:12){
                Button(action: {
                    PopupManager.shared.show(type: .logout, action: viewModel.logout)
                }) {
                    Text("로그아웃")
                        .font(._body1)
                        .foregroundColor(.blue30)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue10)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    PopupManager.shared.show(type: .deleteAccount, action: viewModel.deleteAccount)
                }) {
                    Text("계정삭제")
                        .font(._body1)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.gray10)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .background(.gray00)
        .navigationBarBackButtonHidden(true)
    }
    
    private func setAppearance(isDarkMode: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        withAnimation(.mediumEaseInOut){
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif
