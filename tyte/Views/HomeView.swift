import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel : TodoListViewModel
    @EnvironmentObject private var authViewModel : AuthViewModel
    
    @State private var todoInput = ""
    @State private var dueDate = Date()
    @State private var showSortMenu = false
    @State private var sortOption = "마감 임박순"
    
    var body: some View {
        
        VStack(spacing: 0) {
            // 상단 파란색 영역
            HStack{
                VStack(alignment: .leading, spacing: 16) {
                    HStack{
                        Text("안녕하세요. \(authViewModel.username)님")
                            .font(._subhead1)
                            .foregroundColor(.gray20)
                        
                        Spacer()
                        
                        Text("워라벨 분석 보기")
                            .font(._body3)
                            .foregroundColor(.gray10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .offset(y: 0), alignment: .bottom
                            )
                    }
                    HStack(alignment: .top, spacing:6){
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .padding(.top,8)
                        
                        Text("업무량이 조금씩 증가하고 있습니다. 주의를 기울이세요.")
                            .font(._headline2)
                            .foregroundColor(.gray00)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(.blue30)
            
            VStack(alignment:.leading, spacing: 4) {
                
                ScrollView {
                    HStack {
                        Text("전체 Todo")
                            .font(._headline2)
                            .foregroundColor(.gray90)
                        
                        Text(Date().formattedDate)
                            .font(._title)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Menu {
                            Button("마감 임박") {
                                sortOption = "마감 임박순"
                                viewModel.fetchTodos(mode: "default")
                            }
                            Button("최근 추가") {
                                sortOption = "최근 추가순"
                                viewModel.fetchTodos(mode: "recent")
                            }
                            Button("중요도") {
                                sortOption = "중요도순"
                                viewModel.fetchTodos(mode: "important")
                            }
                        } label: {
                            HStack(spacing:8){
                                Text(sortOption)
                                    .font(._body4)
                                    .foregroundColor(.gray90)
                                
                                Image(systemName: "arrow.up.arrow.down")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.gray60)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.gray00)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray50 , lineWidth: 1)
                            )
                            .shadow(color: .gray90.opacity(0.08), radius: 4)
                            .padding(1)
                        }
                    }
                    // Todo 리스트 영역
                    if (viewModel.totalTodos.count>0){
                        TodoListContent(
                            isHome:true
                        )
                        .onAppear {
                            print("onAppear in Home")
                            viewModel.fetchTodos()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            print("onReceive in Home")
                            viewModel.fetchTodos()
                        }
                    } else {
                        HStack{
                            Spacer()
                            
                            Text("Todo가 없어요")
                                .font(._subhead1)
                                .foregroundColor(.gray50)
                                .padding()
                            
                            Spacer()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
        }
        .background(.gray00)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TodoListViewModel())
            .environmentObject(AuthViewModel())
    }
}
