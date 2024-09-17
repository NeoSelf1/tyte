import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var sharedVM : SharedTodoViewModel
    @StateObject private var viewModel: HomeViewModel
    
    init() {
        let shared = SharedTodoKey.defaultValue
        _viewModel = StateObject(wrappedValue: HomeViewModel(sharedTodoVM: shared))
    }
    
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
            VStack(alignment:.leading, spacing: 0) {
                VStack (spacing: 8) {
                    Text("안녕하세요. 김형석님")
                        .font(._subhead1)
                        .foregroundColor(.gray50)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            SortMenuButton(viewModel: viewModel)
                            
                            TagSelector(viewModel: viewModel)
                        }
                    }
                    
                    TodoViewSelector(viewModel: viewModel)
                }
                .padding(.horizontal)
                
                TabView(selection: $viewModel.currentTab) {
                    ScrollView {
                        ForEach(viewModel.inProgressTodos.filter { todo in
                            if viewModel.selectedTags.contains("default") {
                                return todo.tagId == nil || (todo.tagId != nil && viewModel.selectedTags.contains(todo.tagId!.id))
                            } else {
                                return todo.tagId != nil && viewModel.selectedTags.contains(todo.tagId!.id)
                            }
                        }) { todo in
                            TodoItemView(todo: todo, isHome: true) {_ in viewModel.toggleTodo(todo.id)}
                        }
                        Spacer().frame(height:80)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal)
                    .background(.gray10)
                    .tag(0)
                    
                    ScrollView {
                        ForEach(viewModel.completedTodos.filter { todo in
                            if viewModel.selectedTags.contains("default") {
                                return todo.tagId == nil || (todo.tagId != nil && viewModel.selectedTags.contains(todo.tagId!.id))
                            } else {
                                return todo.tagId != nil && viewModel.selectedTags.contains(todo.tagId!.id)
                            }
                        }) { todo in
                            TodoItemView(todo: todo, isHome: true) {_ in viewModel.toggleTodo(todo.id)}
                        }
                        Spacer().frame(height:80)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal)
                    .background(.gray10)
                    .tag(1)
                }
            }
        }
        .background(.gray00)
    }
}
