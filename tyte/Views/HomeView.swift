import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var sharedVM: SharedTodoViewModel
    
    @Environment(\.colorScheme) var colorScheme
    // @State 프로퍼트를 직접 초기화하려 할 경우, 버그 발생 우려 -> onAppear 수정자에 값 설정 로직 추가
    // SwiftUI 뷰는 값 구조체이며 @State 변경 시 새로운 인스턴스가 생성됨. 즉 뷰가 자주 재생성 된다.
    // @State는 SwiftUI 재생성 로직과 직결되는만큼 뷰의 생명주기와 구분되는 별도의 저장소에 저장 및 관리된다.
    // 허나 init() 메서드는 뷰가 생성될 때마다 호출되기에, 뷰 재생성때마다 상태가 리셋되어 예상치 못한 동작이 발생할 수 있음. 따라서, onAppear 수정자 사용 혹은, initialValue을 통해 뷰가 처음 나타날때만 호출하게끔 해야 함.
    //    init(initialTags: [String]) {
    //        _selectedTags = State(initialValue: initialTags)
    //    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Image(colorScheme == .dark ? "logo-dark" : "logo-light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading,4)
                            .frame(height:30)
                        
                        Spacer()
                        
                        SortMenuButton(viewModel: viewModel)
                    }.frame(height:40)
                        
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            TagSelector(viewModel: viewModel,sharedVM:sharedVM)
                        }
                    }
                    
                    TodoViewSelector(viewModel: viewModel,sharedVM:sharedVM)
                }
                .padding(.horizontal)
                .background(.gray00)
                
                Divider().frame(minHeight:3).background(.gray10)
                
                // 리스트에서 아이템 전체 영역 클릭 가능한 것이 기본 값
                List {
                    ForEach(viewModel.filteredTodos) { todo in
                        HStack(spacing:12){
                            Button(action: {
                                viewModel.toggleTodo(todo.id)
                            }) {
                                Image(todo.isCompleted ? "checked" : "unchecked")
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .padding(.leading,16)
                            
                            TodoItemView(todo: todo, isHome: true)
                                .contentShape(Rectangle())
                                .onTapGesture {}
                        }
                        .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                        .listRowSeparator(.hidden) // 사이 선
                        .listRowBackground(Color.clear)
                        .padding(.top,16)
                        .opacity(todo.isCompleted ? 0.6 : 1.0)
                    }
                }
                .background(.gray10)
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                
                .refreshable(action: {viewModel.fetchTodos()})
            }
        }
    }
}
