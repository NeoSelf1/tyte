import SwiftUI

struct TodoEditBottomSheet: View {
    var tags : [Tag]
    
    @State private var editedTodo: Todo
    
    let onUpdate: (Todo) -> Void
    let onDelete: (String) -> Void
    
    @State private var dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), day: calendar.component(.day, from: Date()))
        let startDate = calendar.date(from: startComponents)!
        
        let endComponents = DateComponents(year: calendar.component(.year, from: Date()) + 1, month: 12, day: 31)
        let endDate = calendar.date(from: endComponents)!
        
        return startDate...endDate
    }()
    
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
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack (alignment:.leading, spacing:6){
                    Text("제목")
                        .font(._body3)
                        .foregroundColor(.gray60)
                        .padding(.leading,4)
                     
                    HStack (spacing: 8) {
                        TextField("새로운 투두 이름 입력...", text: $editedTodo.title)
                            .padding()
                            .background(.gray10)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue10, lineWidth: 1)
                            )
                        
                        Button {
                            let temp = editedTodo.title
                            editedTodo.title=editedTodo.raw
                            editedTodo.raw=temp
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(8)
                                .frame(height: 32)
                                .foregroundColor(.gray60)
                        }
                        
                        
                    }
                    
                    HStack(spacing:4){
                        Text("입력내용:")
                            .font(.caption)
                            .foregroundColor(.gray50)
                        
                        Text(editedTodo.raw)
                            .font(._body3)
                            .foregroundColor(.gray50)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("중요")
                            .font(._body3)
                            .foregroundColor(.gray60)
                            .padding(.leading,4)
                        
                        Toggle("중요",
                               systemImage: editedTodo.isImportant ? "exclamationmark.square.fill" : "exclamationmark.square",
                               isOn: $editedTodo.isImportant
                        )
                        .font(._subhead1)
                        .tint(.blue30)
                        .toggleStyle(.button)
                        .labelStyle(.iconOnly)
                        .contentTransition(.symbolEffect)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("마감날짜")
                            .font(._body3)
                            .foregroundColor(.gray60)
                            .padding(.leading,10)
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { editedTodo.deadline.parsedDate ?? Date() },
                                set: { editedTodo.deadline = $0.apiFormat }
                            ),
                            in: dateRange,
                            displayedComponents: [.date, ]
                        )
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .labelsHidden()
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("태그")
                        .font(._body3)
                        .foregroundColor(.gray60)
                        .padding(.leading,4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags) { tag in
                                HStack (spacing:8) {
                                    Circle().fill(Color(hex:"#\(tag.color)")).frame(width:6)
                                    
                                    Text(tag.name)
                                        .font(tag == editedTodo.tagId ? ._subhead2 : ._body2)
                                        .foregroundColor(.gray90 )
                                    
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(.blue10)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(tag == editedTodo.tagId ? .blue30 : .gray50.opacity(0.0) , lineWidth: 1)
                                )
                                .padding(1)
                                .onTapGesture {
                                    withAnimation(.fastEaseOut){
                                        if(editedTodo.tagId == tag){
                                            editedTodo.tagId = nil
                                        } else {
                                            editedTodo.tagId = tag
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("난이도")
                        .font(._body3)
                        .foregroundColor(.gray60)
                        .padding(.leading,4)
                    
                    Picker("난이도",selection: $editedTodo.difficulty) {
                        ForEach(1...5, id: \.self) { difficulty in
                            Text("\(difficulty)").tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Text("소요 시간")
                    .font(._body3)
                    .foregroundColor(.gray60)
                    .padding(.leading,4)
                
                Text(editedTodo.estimatedTime.formattedDuration)
                    .font(._body1)
                    .foregroundColor(.gray60)
                    .padding(.leading,4)
                    .contentTransition(.numericText(value: Double(editedTodo.estimatedTime)))
                    .animation(.snappy,value: Double(editedTodo.estimatedTime))
                    .frame(maxWidth:.infinity,alignment: .center)
                
                TimeWheelPicker(value: Binding<CGFloat>(
                    get: { CGFloat(editedTodo.estimatedTime) },
                    set: { newValue in
                        var updatedTodo = editedTodo
                        updatedTodo.estimatedTime = Int(round(newValue))
                        editedTodo = updatedTodo
                    }
                ))
                
                HStack{
                    Button(action: {
                        onDelete(editedTodo.id)
                    }) {
                        Text("삭제하기")
                            .font(._title)
                            .padding()
                            .background(.gray20)
                            .foregroundStyle(.gray60)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onUpdate(editedTodo)
                    }) {
                        Text("변경하기")
                            .frame(maxWidth: .infinity)
                            .font(._title)
                            .padding()
                            .background(.blue30)
                            .foregroundStyle(.gray00)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .background(.gray00)
        .environment(\.colorScheme, .light)
    }
}
