import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch(selectedTab) {
                case 0:
                    HomeView()
                case 1:
                    SocialView()
                default:
                    MyPageView()
                }
                bottomTab
            }
        }
    }
    
    @ViewBuilder
    private var bottomTab: some View {
        let tabBarText = [("home","홈"), ("social","소셜"), ("user","MY")]
        ZStack {
            Rectangle()
                .fill(.gray00)
                .frame(height: 72)
                .shadow(color: .gray50.opacity(0.08), radius: 8)
            
            HStack(alignment: .center, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action:{
                        if index==2 && appState.isGuestMode {
                            PopupManager.shared.show(type: .loginRequired, action: UserDefaultsManager.shared.logout)
                        } else {
                            withAnimation(.fastEaseInOut) { selectedTab = index }
                        }
                    } ) {
                        VStack(spacing: 4) {
                            Image(tabBarText[index].0)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width:24,height: 24)
                                .foregroundColor(selectedTab == index ? .blue30 : .gray30)
                                .font(._body4)
                            
                            Text(tabBarText[index].1)
                                .font(._caption)
                                .foregroundColor(selectedTab == index ? .blue30 : .gray50)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 72)
            .background(.gray00)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState.shared)
}
