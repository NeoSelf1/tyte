import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel : TodoListViewModel
    
    @State private var todoInput = ""
    @State private var showSortMenu = false
    @State private var sortOption = "마감 임박순"
    @State private var selectedTags: [String] = []
    
    
    // @State 프로퍼트를 직접 초기화하려 할 경우, 버그 발생 우려 -> onAppear 수정자에 값 설정 로직 추가
    // SwiftUI 뷰는 값 구조체이며 @State 변경 시 새로운 인스턴스가 생성됨. 즉 뷰가 자주 재생성 된다.
    // @State는 SwiftUI 재생성 로직과 직결되는만큼 뷰의 생명주기와 구분되는 별도의 저장소에 저장 및 관리된다.
    // 허나 init() 메서드는 뷰가 생성될 때마다 호출되기에, 뷰 재생성때마다 상태가 리셋되어 예상치 못한 동작이 발생할 수 있음. 따라서, onAppear 수정자 사용 혹은, initialValue을 통해 뷰가 처음 나타날때만 호출하게끔 해야 함.
//    init(initialTags: [String]) {
//        _selectedTags = State(initialValue: initialTags)
//    }
    var body: some View {
        
        VStack(spacing: 0) {
            VStack(alignment:.leading, spacing: 16) {
                VStack (spacing: 8) {
                    Text("안녕하세요. 사용자1님")
                        .font(._subhead1)
                        .foregroundColor(.gray50)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    HStack(alignment: .center,spacing: 8){
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        
                        Text("상태 메시지")
                            .font(._headline2)
                            .foregroundColor(.gray90)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ScrollView(.horizontal){
                        HStack{
                            SortMenuButton(sortOption: $sortOption)
                            
                            TagSelector(selectedTags: $selectedTags)
                                
                        }
                    }
                }
                
                ScrollView {
                    Spacer().frame(height:16)
                    
                    if (viewModel.totalTodos.count>0){
                        TodoListContent(
                            isHome:true,
                            selectedTags: $selectedTags
                        )
                        .onAppear {
                            viewModel.fetchTodos()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
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
                .background(.gray10)
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
            .environmentObject(TagEditViewModel())
    }
}
