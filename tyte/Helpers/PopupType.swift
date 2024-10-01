import Foundation
import Alamofire

enum PopupType {
    case invalidTodo
    case todoAddedIn(String)
    case todosAdded(Int)
    case todoDeleted
    case error(String)
    case tagAdded
    case tagEdited
    case tagDeleted
    
    var text: String{
        switch self {
        case .invalidTodo:
            return "앗! AI가 할 일 내용을 이해하지 못했어요. 다시 한 번 작성해 주시겠어요?"
        case .todoAddedIn(let date):
            return "\(date.parsedDate.formattedMonthDate)에 투두가 추가되었습니다."
        case .todosAdded(let count):
            return "총 \(count)개의 투두가 추가되었습니다."
        case  .todoDeleted:
            return "투두가 삭제되었습니다."
        case .tagAdded:
            return "태그가 추가되었습니다."
        case .tagEdited:
            return "태그가 변경되었습니다."
        case .tagDeleted:
            return "태그가 삭제되었습니다."
        case .error(let message):
            return message
        }
    }
    
    var icon: String {
        switch self {
        case .error, .invalidTodo:
            return "exclamationmark.circle.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
}
