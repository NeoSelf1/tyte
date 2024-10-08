import SwiftUI

struct TodoItemView: View {
    let todo: Todo
    let isHome: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(todo.title)
                        .font(todo.isImportant ? ._subhead1 : ._title)
                        .foregroundColor(.gray90)
                    
                    HStack(spacing: 4) {
                        if isHome {
                            Text(todo.deadline).font(._caption).foregroundColor(.gray50)
                            Circle().fill(.gray50).frame(width: 2, height: 2)
                        }
                        Text("난이도: \(todo.difficulty)/5").font(._caption).foregroundColor(.gray50)
                    }
                }
                
                Spacer()
                
                Text(todo.estimatedTime.formattedDuration)
                    .font(._body2)
                    .padding(.trailing)
                    .foregroundColor(.gray50)
            }
            
            HStack(spacing: 8) {
                Image(systemName: todo.isLife ? "bolt.heart.fill" : "latch.2.case.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray50)
                
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
            }
        }
    }
}
