import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var popupManager = PopupManager.shared
    @StateObject private var offlineUiManager = OfflineUIManager.shared
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.isLoggedIn || appState.isGuestMode {
                MainTabView()
            } else {
                OnboardingView()
            }
            
            if viewModel.isLoading { ProgressView() }
        }
        .presentToast(
            isPresented: $toastManager.toastPresented,
            data: toastManager.currentToastData
        )
        .presentPopup(
            isPresented: $popupManager.popupPresented,
            data: popupManager.currentPopupData
        )
        .presentOfflineUI(
            isPresented: $offlineUiManager.offlineUIPresented
        )
    }
}
