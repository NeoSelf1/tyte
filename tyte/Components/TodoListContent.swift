//
//  TodoListView.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct TodoListContent: View {
    // MARK: 아래 코드의 경우 독자적인 TodoListViewModel 인스턴스를 생성하고 있기에, ListView에서 조작하고 있는 ViewModel 데이터에 닿지 않는다.
    // 1. @ObservedObject private var viewModel = TodoListViewModel()
    
    // 2. 부모로부터 TodoListContent(viewModel: viewModel)와 같이, viewModel을 직접 전달하여 아래와 같이 접근하거나
    // 3. todos, onToggle만을 직접 전달받도록 범위를 줄여, 컴포넌트간의 결합도 낮추고, 데이터 흐름 명확히 명시
    // 4. 두개이상의 자식,부모 뷰가 동일한 ViewModel을 사용하기에, 인자로 넘겨 사용하는 것에 가독성이 떨어질 경우, Environment로 공유
    // 5. 이럴경우, State가 변경되어도, ListView에서 이를 감지하지 못함 -> EnvironmentObject에서 ObservedObject로 롤백
//    @ObservedObject var viewModel: TodoListViewModel
    
    @EnvironmentObject var viewModel: TodoListViewModel
    
    
    let isHome: Bool
    @Binding var selectedTags: [String]
    private var shouldPresentSheet: Binding<Bool> {
        Binding(
            get: { isBottomSheetPresented && selectedTodo != nil },
            set: { isBottomSheetPresented = $0 }
        )
    }
    
    // BottomSheet에서 변수내용 변경 시, 재렌더되게끔 @State 프로토콜 선언
    @State private var selectedTodo: Todo?
    @State private var isBottomSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing:16) {
            ForEach(isHome ?
                    viewModel.totalTodos.filter { todo in
                guard let todoTagId = todo.tagId?.id else { return false }
                return selectedTags.contains(todoTagId)
            } : viewModel.todosForDate) { todo in
                HStack (spacing:12) {
                    Button(action: {
                        viewModel.toggleTodo(todo.id,isTotal: isHome)
                    }) {
                        Image(todo.isCompleted ? "checked" : "unchecked")
                            .contentTransition(.symbolEffect(.replace))
                    }.frame(width:40,height:40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                            VStack(alignment: .leading,spacing: 0){
                                Text(todo.title)
                                    .font(todo.isImportant ? ._subhead1 : ._title)
                                    .foregroundColor(todo.isCompleted ? .gray50 : .gray90)
                                
                                HStack (spacing: 4){
                                    if (isHome) {
                                        Text(todo.deadline).font(._caption).foregroundColor(.gray50)
                                        Circle().background(.gray50).frame(width: 2,height: 2)
                                    }
                                    
                                    Text("난이도: \(todo.difficulty)/5").font(._caption).foregroundColor(.gray50)
                                }
                            }
                            Spacer()
                            
                            Text(todo.estimatedTime.formattedDuration)
                                .font(._body2)
                                .foregroundColor(.gray50)
                        }
                        
                        HStack(spacing:8) {
                            Image(systemName: todo.isLife ? "bolt.heart.fill" : "latch.2.case.fill")
                                .resizable()
                                .frame(width: 12,height:12)
                                .foregroundColor(.gray50)
                            if(todo.tagId != nil){
                                HStack (spacing:4) {
                                    Circle().fill(Color(hex:"#\(todo.tagId!.color)")).frame(width:6)
                                    
                                    Text(todo.tagId!.name)
                                        .font(._caption)
                                        .foregroundColor(.gray60)
                                    
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.blue10)
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                .onTapGesture {
                    if (!isHome) {
                        selectedTodo = todo
                        isBottomSheetPresented = true
                    }
                }
            }
        }
        .sheet(isPresented: shouldPresentSheet) {
            if let todo = selectedTodo {
                TodoEditBottomSheet(
                    todo: todo,
                    onUpdate: { updatedTodo in
                        viewModel.editTodo(updatedTodo)
                        isBottomSheetPresented = false
                    },
                    onDelete: { id in
                        viewModel.deleteTodo(id: id)
                        isBottomSheetPresented = false
                    }
                )
                .presentationDetents([.height(600)])
            }
        }
        Spacer().frame(height:120)
        
    }
}
