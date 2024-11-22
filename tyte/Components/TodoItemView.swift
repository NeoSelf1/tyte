import SwiftUI

struct TodoItemView: View {
    let todo: Todo
    let isPast: Bool
    let isButtonPresent: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing:8) {
            if isButtonPresent {
                Button(action: onToggle) {
                    Image(todo.isCompleted ? "checked" : "unchecked")
                        .resizable()
                        .frame(width: 32,height:32)
                        .foregroundStyle(.gray60)
                }
                .padding(.leading,16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(todo.isImportant ? ._subhead1 : ._title)
                    .foregroundColor(.gray90)
                
                HStack(spacing: 4) {
                    if let tagId = todo.tagId {
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: "#\(tagId.color)")).frame(width: 6)
                            Text(tagId.name)
                                .font(._caption)
                                .foregroundColor(.gray60)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(.blue10)
                        .cornerRadius(20)
                    }
                    
                    Text("난이도: \(todo.difficulty)/5")
                        .font(._caption)
                        .foregroundColor(.gray50)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Image(systemName: todo.isLife ? "bolt.heart.fill" : "latch.2.case.fill")
                    .font(._body4)
                
                Text(todo.estimatedTime.formattedDuration)
                    .font(._body2)
                    .padding(.trailing)
            }
            .foregroundColor(.gray50)
        }
        .onTapGesture { onSelect() }
        .opacity(!isPast && !todo.isCompleted ? 1.0 : 0.6)
    }
}
