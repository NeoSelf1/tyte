import SwiftUI

struct TodoViewSelector: View {
    @ObservedObject var viewModel: HomeViewModel
    private let animationDuration: Double = 0.2
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(title: "진행중 Todo (\(viewModel.inProgressTodos.count))", tab: 0, geometry: geometry)
                    tabButton(title: "완료된 Todo (\(viewModel.completedTodos.count))", tab: 1, geometry: geometry)
                }
                
                Rectangle()
                    .fill(.gray90)
                    .frame(width: geometry.size.width / 2, height: 3)
                    .offset(x: viewModel.currentTab == 0 ? 0 : geometry.size.width / 2)
                    .animation(.easeInOut(duration: animationDuration), value: viewModel.currentTab)
             
            }
        }
        .frame(height: 48)
    }
    
    private func tabButton(title: String, tab: Int, geometry: GeometryProxy) -> some View {
        Button(action: {
            withAnimation(.fastEaseOut) {
                viewModel.currentTab = tab
            }
        }) {
            Text(title)
                .font(._subhead1)
                .foregroundStyle(viewModel.currentTab == tab ? .gray90 : .gray50)
                .frame(width: geometry.size.width / 2, height: 45, alignment: .center)
        }
        .animation(.easeOut(duration: animationDuration), value: viewModel.currentTab)
    }
}
