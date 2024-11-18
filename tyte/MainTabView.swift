import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
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
            bottomTab
        }
        .animation(.spring,value:selectedTab)
        .background(.gray00)
    }
    
    @ViewBuilder
    private var bottomTab: some View {
        let tabBarText = [("home","홈"), ("magnifyingglass","소셜"), ("user","MY")]
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
                        if index==2 && appState.isGuestMode {
                            appState.showPopup(type: .loginRequired, action: UserDefaultsManager.shared.logout)
                        } else {
                            selectedTab = index
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