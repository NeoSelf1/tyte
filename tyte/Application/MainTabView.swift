import SwiftUI

/// 앱의 메인 탭 기반 네비게이션 구조를 구현하는 뷰입니다.
///
/// `MainTabView`는 다음 기능을 제공합니다:
/// - 홈, 소셜, MY 화면 간 탭 기반 네비게이션
/// - 게스트 모드 접근 제한 처리
/// - 탭 별 아이콘 및 선택 상태 관리
///
/// ## 탭 구성
/// 앱은 세 가지 주요 탭으로 구성됩니다:
/// ```swift
/// enum Tab {
///     case home    // 할 일 관리 화면
///     case social  // 친구 관리 화면
///     case myPage  // 개인 설정 화면
/// }
/// ```
///
/// ## 주요 UI 컴포넌트
/// ### NavigationStack
/// - 각 탭 내부의 화면 스택 관리
/// - 하위 화면으로의 네비게이션 지원
///
/// ### BottomTabBar
/// - 커스텀 디자인된 하단 탭 바
/// - 선택된 탭 하이라이트 처리
/// - 알림 배지 표시 (소셜 탭)
///
/// ## 접근 제한
/// - MY 탭은 게스트 모드에서 접근 제한
/// - 제한된 기능 접근 시 로그인 팝업 표시
///
/// ## 사용 예시
/// ```swift
/// MainTabView()
///     .environmentObject(appState)  // 전역 상태 접근용
/// ```
///
/// - Note: 로그인/게스트 모드 상태는 `AppState`를 통해 관리됩니다.
/// - Important: 탭 간 전환 시 이전 탭의 상태는 유지됩니다.
/// - Warning: 게스트 모드에서는 일부 기능이 제한됩니다.
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
                            PopupManager.shared.show(
                                type: .loginRequired,
                                action: { appState.isGuestMode=false }
                            )
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
