import SwiftUI
import GoogleSignIn

@main
struct tyteApp: App {
    @StateObject private var appState = AppState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    // 앱이 포그라운드에서 실행 중일 때 URL 처리
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

// 앱이 백그라운드 상태이거나 실행되지 않은 상태에서 URL을 통해 앱이 실행될 때
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

//MARK: - Toast, Popup 상태관리 및 온보딩 vs 메인화면 관리
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var isToastPresent = false
    @State private var isPopupPresent = false
    
    var body: some View {
        ZStack {
            if appState.isLoggedIn || appState.isGuestMode { // 게스트모드일 때에도 부분적으로 MainTabView 접근할 수 있도록 조건 추가
                MainTabView()
            } else {
                OnboardingView()
                    .ignoresSafeArea()
            }
            
            if let popup = appState.currentPopup {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .opacity(isPopupPresent ? 0.3 : 0.0)
                    .onTapGesture { hidePopup() }
                    .animation(.spring(duration:0.1),value:isPopupPresent)
                
                CustomPopup(hidePopup:hidePopup, popupData: popup)
                    .opacity(isPopupPresent ? 1 : 0)
                    .offset(y: isPopupPresent ? 0 : -80)
                    .animation(.spring(duration:0.3),value:isPopupPresent)
            }
            
            if let toast = appState.currentToast {
                CustomToast(toastData: toast)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 40)
                    .zIndex(1)
                    .opacity(isToastPresent ? 1 : 0)
                    .offset(y: isToastPresent ? 0 : -80)
                    .animation(.spring(duration:0.5),value:isToastPresent)
            }
        }
        .onChange(of: appState.currentToast?.type) { _, newToast in
            handleToastChange(newToast,in: 3.0)
        }
        .onChange(of: appState.currentPopup?.type) { _, newPopup in
            handlePopupChange(newPopup)
        }
    }
    
    private func handlePopupChange(_ newPopup:PopupType?){
        if newPopup != nil { isPopupPresent = true }
    }
    
    private func hidePopup(){
        isPopupPresent = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.removePopup()
        }
    }
    
    private func handleToastChange(_ newToast: ToastType?, in interval:Double) {
        if newToast != nil {
            isToastPresent = true
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                isToastPresent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    appState.removeToast()
                }
            }
        }
    }
}
