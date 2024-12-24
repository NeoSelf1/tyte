import SwiftUI

enum TodoEditRoute: Hashable {
    case timePicker
    case datePicker
}

struct TodoEditBottomSheet: View {
    var tags : [Tag]
    
    @State private var navigationPath = NavigationPath()
    @State private var editedTodo: Todo
    
    let onUpdate: (Todo) -> Void
    let onDelete: (String) -> Void
    
    init(tags:[Tag],
         todo: Todo,
         onUpdate: @escaping (Todo) -> Void,
         onDelete: @escaping (String) -> Void
    ) {
        self.tags = tags
        _editedTodo = State(initialValue: todo)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 16) {
                nameSection
                tagSection
                difficultySection
                    .padding(.bottom, 12)
                
                linkBtn(
                    title: "마감날짜",
                    description: editedTodo.deadline.parsedDate.formattedDate,
                    destination: .datePicker
                )
                
                linkBtn(
                    title: "소요시간",
                    description: editedTodo.estimatedTime.formattedDuration,
                    destination: .timePicker
                )
                
                Spacer()
                
                bottomTabBar
            }
            .padding(16)
            .background(.gray00)
            
            .navigationDestination(for: TodoEditRoute.self) { route in
                switch route {
                case .timePicker:
                    TimePickerView(estimatedTime: $editedTodo.estimatedTime)
                case .datePicker:
                    DatePickerView(deadline: $editedTodo.deadline)
                }
            }
        }
    }
}

#Preview {
    TodoEditBottomSheet(
        tags: [Tag.mock],
        todo: Todo.mock,
        onUpdate: {_ in print("onUpdate")},
        onDelete: {_ in print("onUpdate")}
    )
    .frame(maxHeight: 520)
    .border(.gray50)
}


//MARK: - 하위 메서드

extension TodoEditBottomSheet {
    private func linkBtn(title: String, description:String ,destination: TodoEditRoute) -> some View {
        Button(action: {
            navigationPath.append(destination)
        }) {
            HStack(spacing: 6) {
                Text(title)
                    .font(._body2)
                    .foregroundColor(.gray50)
                
                Spacer()
                
                Text(description)
                    .font(._body1)
                    .foregroundColor(.gray90)
                
                Image("arrow_right")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.gray50)
                    .frame(width:16,height: 16)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray10)
                    .stroke(.gray20)
            )
        }
    }
    
    private func checkboxBtn(_ isChecked: Binding<Bool>, _ title: String) -> some View {
        Button(action: {
            isChecked.wrappedValue.toggle()
        }) {
            HStack(spacing:4) {
                Image("checkbox_filled")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(isChecked.wrappedValue ? .gray60 : .gray30)
                    .frame(width:16,height: 16)
                
                Text(title)
                    .font(._body3)
                    .foregroundColor(isChecked.wrappedValue ? .gray60 : .gray50)
            }
            .padding(.horizontal,4)
            .padding(.vertical,6)
        }
    }
}


//MARK: - 하위 컴포넌트

extension TodoEditBottomSheet {
    private var bottomTabBar: some View {
        HStack {
            Button(action: {
                onDelete(editedTodo.id)
            }) {
                Text("삭제하기")
                    .font(._body2)
                    .foregroundStyle(.gray60)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray10))
            }
            
            Button(action: {
                onUpdate(editedTodo)
            }) {
                Text("변경하기")
                    .font(._body2)
                    .foregroundStyle(.gray00)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.blue30))
            }
        }
    }
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("난이도")
                .font(._body2)
                .foregroundColor(.gray50)
            
            Picker("난이도",selection: $editedTodo.difficulty) {
                ForEach(1...5, id: \.self) { difficulty in
                    Text("\(difficulty)").tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("태그")
                .font(._body2)
                .foregroundColor(.gray50)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags) { tag in
                        Button(action: {
                            withAnimation(.fastEaseOut){
                                if(editedTodo.tagId == tag){
                                    editedTodo.tagId = nil
                                } else {
                                    editedTodo.tagId = tag
                                }
                            }
                        }) {
                            HStack (spacing:8) {
                                Circle().fill(Color(hex:"#\(tag.color)")).frame(width:6)
                                
                                Text(tag.name)
                                    .font(tag == editedTodo.tagId ? ._subhead2 : ._body2)
                                    .foregroundColor(.gray90)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(.blue10)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(tag == editedTodo.tagId ? .blue30 : .clear, lineWidth: 1)
                            )
                            .padding(1)
                        }
                    }
                }
            }
        }
    }
    
    private var nameSection: some View {
        VStack (alignment:.leading, spacing:8){
            HStack(spacing:8) {
                Text("제목")
                    .font(._body2)
                    .foregroundColor(.gray50)
                
                Spacer()
                
                checkboxBtn($editedTodo.isImportant, "중요")
                checkboxBtn($editedTodo.isLife, "생활 관련")
            }
             
            VStack (spacing: 12) {
                TextField("새로운 투두 이름 입력...", text: $editedTodo.title)
                    .font(._title)
                
                Button {
                    let temp = editedTodo.title
                    editedTodo.title = editedTodo.raw
                    editedTodo.raw = temp
                } label: {
                    HStack(spacing:4){
                        Image("arrow_exchange")
                            .resizable()
                            .frame(width:16,height: 16)
                            .foregroundColor(.gray60)
                        
                        Text("초기 입력내용:")
                            .font(._caption)
                            .foregroundColor(.gray60)
                        
                        Text(editedTodo.raw)
                            .font(._caption)
                            .foregroundColor(.gray50)
                            .padding(.leading,4)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue10)
                    )
                }
            }
            .padding(.vertical,12)
            .padding(.horizontal,14)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray10)
                    .stroke(.gray20, lineWidth: 1)
            )
        }
    }
}
