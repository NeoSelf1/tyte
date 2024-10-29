import Foundation
import Alamofire

enum ToastType {
    case friendRequested(String) // username
    case friendAlreadyRequested(String) // username
    case friendRequestAccepted(String) // username
    case invalidTodo
    case todoAddedIn(String)
    case todosAdded(Int)
    case todoDeleted
    case tagAdded
    case tagEdited
    case tagDeleted
    case googleError
    
    case error(String)
    
    var text: String{
        switch self {
        case .friendRequested(let username):
            return "\(username)님에 대한 친구 요청이 완료되었습니다."
        case .friendAlreadyRequested(let username):
            return "\(username)님에 대해 친구요청 진행중입니다."
        case .friendRequestAccepted(let username):
            return "\(username)님의 친구요청을 수락했습니다."
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
        case .googleError:
            return "구글 로그인이 잠시 안되고 있어요. 나중에 다시 시도해주세요."
        case .error(let message):
            return message
        }
    }
    
    var icon: String {
        switch self {
        case .error, .invalidTodo, .googleError:
            return "exclamationmark.circle.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
}
