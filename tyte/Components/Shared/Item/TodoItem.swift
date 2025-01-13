/// 할 일 항목을 표시하는 리스트 아이템 컴포넌트
///
/// 할 일의 제목, 태그, 난이도, 예상 소요시간 등의 정보를 표시하며,
/// 완료 여부 토글 기능과 수정을 위한 선택 기능을 제공합니다.
///
/// - Parameters:
///   - todo: 표시할 할 일 데이터
///   - isPast: 과거 데이터 여부
///   - isButtonPresent: 완료 토글 버튼 표시 여부
///   - onToggle: 완료 상태 변경 콜백
///   - onSelect: 항목 선택 콜백
///
/// - Note: HomeView의 할 일 목록과 DetailSection의 완료된 할 일 목록에서 사용됩니다.
import SwiftUI

struct TodoItem: View {
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
                    if let tag = todo.tag {
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: "#\(tag.color)")).frame(width: 6)
                            Text(tag.name)
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
            
            VStack(alignment:.trailing, spacing: 4) {
                Image(systemName: todo.isLife ? "bolt.heart.fill" : "latch.2.case.fill")
                    .font(._body4)
                
                Text(todo.estimatedTime.formattedDuration)
                    .font(._body2)
            }
            .foregroundColor(.gray50)
            .padding(.trailing)
        }
        .onTapGesture { onSelect() }
        .opacity(!isPast && !todo.isCompleted ? 1.0 : 0.6)
    }
}
