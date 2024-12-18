import SwiftUI

struct ViewSelector: View {
    @Binding var currentTab: Int
    let width: CGFloat
    private let animationDuration: Double = 0.2
    
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
                    .offset(x: currentTab == 0 ? 0 : geometry.size.width / 2, y: -3)
                    .animation(.easeInOut(duration: animationDuration), value: currentTab)
            }
        }
        .frame(width:width, height: 44)  // 적절한 높이 설정
    }
    
    private func tabButton(title: String, tab: Int, geometry: GeometryProxy) -> some View {
        Button(action: {
            currentTab = tab
        }) {
            Text(title)
                .font(._subhead2)
                .foregroundStyle(currentTab == tab ? .gray90 : .gray50)
                .frame(width: geometry.size.width / 2, height: 40,alignment: .center)
        }
        .animation(.easeOut(duration: animationDuration), value: currentTab)
    }
}

