import SwiftUI

struct ViewSelector: View {
    // MARK: StateObject는 객체의 소유권과 생명주기를 관리하는데 사용
    @ObservedObject var viewModel : MyPageViewModel
    
    private let animationDuration:Double = 0.2
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment:.leading,spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(title: "달력", tab: 0, geometry: geometry)
                    tabButton(title: "그래프", tab: 1, geometry: geometry)
                }
                
                // geometry.size.width를 활용해 offset.x를 변경
                Rectangle()
                    .fill(.gray90)
                    .frame(width: geometry.size.width / 2, height: 3)
                    .offset(x: viewModel.currentTab == 0 ? 0 : geometry.size.width / 2, y: -3)
                    .animation(.easeInOut(duration: animationDuration), value: viewModel.currentTab)
            }
        }
        .frame(height: 44)  // 적절한 높이 설정
    }
    
    private func tabButton(title: String, tab: Int, geometry: GeometryProxy) -> some View {
        Button(action: {
            withAnimation(.fastEaseOut) {
                viewModel.currentTab = tab
            }
        }) {
            Text(title)
                .font(._subhead2)
                .foregroundStyle(viewModel.currentTab == tab ? .gray90 : .gray50)
                .frame(width: geometry.size.width / 2, height: 40,alignment: .center)
        }
        .animation(.easeOut(duration: animationDuration), value: viewModel.currentTab)
    }
}

