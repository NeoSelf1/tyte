import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var sharedVM = SharedTodoViewModel()
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var listVM: ListViewModel
    
    init() {
        let shared = SharedTodoViewModel()
        _sharedVM = StateObject(wrappedValue: shared)
        _homeVM = StateObject(wrappedValue: HomeViewModel(sharedVM: shared))
        _listVM = StateObject(wrappedValue: ListViewModel(sharedVM: shared))
    }
    
    @State private var selectedTab = 0
    @State private var isCreateTodoViewPresented = false
    @State private var isPopupPresented = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                switch(selectedTab) {
                case 0:
                    HomeView(viewModel: homeVM, sharedVM: sharedVM)
                case 1:
                    NavigationStack {
                        ListView(viewModel: listVM, sharedVM: sharedVM)
                    }
                default:
                    NavigationStack {
                        MyPageView()
                    }
                }
                BottomTab(selectedTab: $selectedTab, sharedVM:sharedVM)
            }
            .background(.gray00)
            
            FloatingActionButton(action: {
                if appState.isGuestMode {
                    withAnimation(.mediumEaseInOut) {
                        sharedVM.isLoginRequiredViewPresented = true
                    }
                } else {
                    isCreateTodoViewPresented = true
                }
            })
            .padding(.trailing, 24)
            .padding(.bottom, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
            
            if isPopupPresented, let popup = sharedVM.currentPopup {
                CustomPopup(popup: popup)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 40)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .animation(.mediumEaseInOut, value: isPopupPresented)
            }
            
            if sharedVM.isLoginRequiredViewPresented {
                CustomAlert(
                    isShowing: $sharedVM.isLoginRequiredViewPresented,
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
        .onAppear {
            listVM.setupBindings(sharedVM: sharedVM)
            homeVM.setupBindings(sharedVM: sharedVM)
        }
        .sheet(isPresented: $isCreateTodoViewPresented) {
            CreateTodoView(sharedVM: sharedVM, isShowing: $isCreateTodoViewPresented)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.gray00)
        }
        .onChange(of: sharedVM.currentPopup?.text) { _, newValue in
            if newValue != nil {
                withAnimation {
                    isPopupPresented = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isPopupPresented = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        sharedVM.currentPopup = nil
                    }
                }
            }
        }
    }
}

struct BottomTab: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: Int
    var sharedVM : SharedTodoViewModel
    
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
                        if index==2 && appState.isGuestMode {
                            withAnimation(.mediumEaseInOut) {
                                sharedVM.isLoginRequiredViewPresented = true
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
}
