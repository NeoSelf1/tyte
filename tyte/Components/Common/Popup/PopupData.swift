struct PopupData {
    let type: PopupType
    let action: () -> Void
}

enum PopupType: Equatable {
    case acceptFriend(username: String)
    case loginRequired
    case logout
    case deleteAccount
    
    var isBtnHorizontal: Bool {
        switch self {
        case .logout, .deleteAccount:
            return true
        default:
            return false
        }
    }
    
    var title: String {
        switch self {
        case .acceptFriend(let username):
            return username
        case .loginRequired:
            return "로그인 필요"
        case .logout:
            return "로그아웃"
        case .deleteAccount:
            return "계정삭제"
        }
    }
    
    var description: String {
        switch self {
        case .acceptFriend:
            return "친구 요청을 수락하시겠습니까?"
        case .loginRequired:
            return "로그인이 필요한 기능입니다"
        case .logout:
            return "정말로 로그아웃 하시겠습니까?"
        case .deleteAccount:
            return "정말로 계정을 삭제하시겠습니까?"
        }
    }
    
    var primaryButtonText: String {
        switch self {
        case .acceptFriend:
            return "수락하기"
        case .loginRequired:
            return "로그인"
        case .logout:
            return "로그아웃"
        case .deleteAccount:
            return "계정삭제"
        }
    }
    
    var secondaryButtonText: String {
        switch self {
        case .acceptFriend:
            return "돌아가기"
        case .loginRequired, .logout, .deleteAccount:
            return "취소"
        }
    }
}
