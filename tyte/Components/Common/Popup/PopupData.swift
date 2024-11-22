struct PopupData {
    let type: PopupType
    let action: () -> Void
}

enum PopupType: Equatable {
    case acceptFriend(username: String)
    case loginRequired
    case logout
    case deleteAccount
    case update
    
    var isMandatory: Bool {
        switch self {
        case .update:
            true
        default:
            false
        }
    }
    
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
        case .update:
            return "새로운 버전 안내"
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
        case .update:
            return "더 나은 서비스 제공을 위해\n새로운 기능과 개선사항이 추가되었어요"
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
        case .update:
            return "지금 업데이트하기"
        }
    }
    
    var secondaryButtonText: String {
        switch self {
        case .acceptFriend:
            return "돌아가기"
        case .loginRequired, .logout, .deleteAccount:
            return "취소"
        default:
            return ""
        }
    }
}
