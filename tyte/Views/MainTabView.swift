import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedTab = 1
    @State private var isToastPresented = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationStack {
                    switch(selectedTab) {
                    case 0:
                        HomeView()
                    case 1:
                        SocialView()
                    default:
                        MyPageView()
                    }
                }
                BottomTab(selectedTab: $selectedTab)
            }
            .background(.gray00)
            
            if isToastPresented, let toast = appState.currentToast {
                CustomToast(toastData: toast)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 40)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .animation(.mediumEaseInOut, value: isToastPresented)
            }
            
            if appState.isLoginRequiredViewPresented {
                CustomPopupTwoBtn(
                    isShowing: $appState.isLoginRequiredViewPresented,
                    title: "로그인 필요",
                    message: "로그인이 필요한 기능입니다",
                    primaryButtonTitle: "로그인",
                    secondaryButtonTitle: "취소",
                    primaryAction: {
                        appState.isGuestMode = false
                    },
                    secondaryAction: {}
                )
            }
        }
        .onChange(of: appState.currentToast?.text) { _, newValue in
            if newValue != nil {
                withAnimation {
                    isToastPresented = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isToastPresented = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        appState.currentToast = nil
                    }
                }
            }
        }
    }
}

struct BottomTab: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        let tabBarText = [("home","홈"), ("calendar","일정관리"), ("user","MY")]
        
        ZStack {
            Rectangle()
                .fill(.gray00)
                .shadow(color: .gray50.opacity(0.08), radius: 8)
            
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    TabBarButton(
                        icon: tabBarText[index].0,
                        text: tabBarText[index].1,
                        isSelected: selectedTab == index
                    ) {
                        if index==2 && AppState.shared.isGuestMode {
                            withAnimation(.mediumEaseInOut) {
                                AppState.shared.isLoginRequiredViewPresented = true
                            }
                        } else {
                            withAnimation(.fastEaseInOut) {
                                selectedTab = index
                            }
                        }
                    }
                }
            }
            .background(.gray00)
        }
        .frame(height: 56)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState.shared)
}
