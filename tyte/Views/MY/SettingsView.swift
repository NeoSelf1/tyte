import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            Toggle(isOn: $isDarkMode) {
                Text("다크모드")
                    .font(._body2)
                    .foregroundColor(.gray90)
            }
            .padding()
            .tint(.blue30)
            .background(Color.gray10)
            .cornerRadius(8)
            .onChange(of: isDarkMode) { _,newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    setAppearance(isDarkMode: newValue)
                }
            }
            
            Divider()
                .padding(.vertical,12)
            
            VStack(spacing:12){
                Button(action: {
                    appState.showPopup(type: .logout, action: viewModel.logout)
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
                    appState.showPopup(type: .deleteAccount, action: viewModel.deleteAccount)
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
        .padding()
        .background(.gray00)
        
        .navigationBarTitle("설정", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
    }
}

private func setAppearance(isDarkMode: Bool) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}

#Preview{
    SettingsView()
}
