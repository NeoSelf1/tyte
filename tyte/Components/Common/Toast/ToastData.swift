struct ToastData {
    let type: ToastType
    let action: (() -> Void)?
}

enum ToastType:Equatable {
    case friendRequested(String) // username
    case friendAlreadyRequested(String) // username
    case friendRequestAccepted(String) // username
    case invalidTodoEdit
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
            "\(username)님에 대한 친구 요청이 완료되었습니다."
        case .friendAlreadyRequested(let username):
            "\(username)님에 대해 친구요청 진행중입니다."
        case .friendRequestAccepted(let username):
            "\(username)님의 친구요청을 수락했습니다."
        case .todoAddedIn(let date):
            "\(date.parsedDate.formattedMonthDate)에 투두가 추가되었습니다."
        case .todosAdded(let count):
            "총 \(count)개의 투두가 추가되었습니다."
        case  .todoDeleted:
            "투두가 삭제되었습니다."
        case .tagAdded:
            "태그가 추가되었습니다."
        case .tagEdited:
            "태그가 변경되었습니다."
        case .tagDeleted:
            "태그가 삭제되었습니다."
        case .invalidTodoEdit:
            "이전 투두들은 수정이 불가능해요."
        case .googleError:
            "구글 로그인이 잠시 안되고 있어요. 나중에 다시 시도해주세요."
        case .error(let message):
            message
        }
    }
    
    var icon: String {
        switch self {
        case .error, .googleError:
            "exclamationmark.circle.fill"
        default:
            "checkmark.circle.fill"
        }
    }
    
    var button: String? {
        switch self {
        case .todoAddedIn:
            "Todo 확인하기"
        default:
            nil
        }
    }
}
