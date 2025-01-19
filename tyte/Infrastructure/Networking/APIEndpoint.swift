import Foundation

/// API 엔드포인트를 정의하는 파일입니다.
/// 앱에서 사용하는 모든 API 경로와 파라미터를 캡슐화합니다.
///
/// ## 기능별 엔드포인트 그룹
/// - 인증: ``login``, ``signUp``, ``validateToken``
/// - Todo 관리: ``fetchTodosForDate``, ``createTodo``, ``updateTodo``
/// - 태그 관리: ``fetchTags``, ``createTag``, ``updateTag``
/// - 통계: ``fetchDailyStatsForDate``, ``fetchMonthlyStats``
/// - 소셜: ``searchUser``, ``getFriends``, ``requestFriend``
///
/// ## 사용 예시
/// ```swift
/// let endpoint = APIEndpoint.login
/// let path = endpoint.path  // "/auth/login"
/// ```
///
/// - Important: 모든 엔드포인트는 `APIConstants.baseUrl`과 결합되어 완전한 URL을 형성합니다.
/// - Note: 각 엔드포인트는 필요한 파라미터를 연관값으로 포함합니다.
enum APIEndpoint {
    case login
    case signUp
    case checkEmail
    case checkVersion
    case validateToken
    case socialLogin(String) // Provider
    
    case fetchTodosForDate(String) // Deadline
    case fetchFriendTodosForDate(friendId:String, deadline:String)
    
    case createTodo
    case toggleTodo(String) // todoId
    case updateTodo(String)  // todoId
    case deleteTodo(String)  // todoId
    
    case fetchTags
    case createTag
    case updateTag(String)  // tagId
    case deleteTag(String)  // tagId
    
    case fetchDailyStatsForDate(String) // date
    case fetchDailyStatsForMonth(String) // yearMonth
    case getFriendDailyStats(friendId: String, yearMonth: String) // 친구의 DailyStat 조회
    
    case searchUser(String) // query
    case getFriends
    case requestFriend(String) // userId
    case getPendingRequests // 받은 친구 요청 목록 조회
    case acceptFriendRequest(String) // requestId
    case removeFriend(String) // friendId
    
    case deleteAccount
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        case .validateToken:
            return "/auth/validate-token"
        case .checkEmail:
            return "/auth/check"
        case .checkVersion:
            return "/auth/version"
        case .socialLogin(let provider):
            return "/auth/\(provider)"
            
        case .fetchTodosForDate(let deadline):
            return "/todo/\(deadline)"
        case .fetchFriendTodosForDate(let friendId, let deadline):
            return "/todo/friend/\(friendId)/\(deadline)"
        case .createTodo:
            return "/todo"
        case .toggleTodo(let todoId):
            return "/todo/toggle/\(todoId)"
        case .updateTodo(let todoId):
            return "/todo/\(todoId)"
        case .deleteTodo(let todoId):
            return "/todo/\(todoId)"
            
        case .fetchTags:
            return "/tag"
        case .createTag:
            return "/tag"
        case .updateTag(let tagId):
            return "/tag/\(tagId)"
        case .deleteTag(let tagId):
            return "/tag/\(tagId)"
            
        case .fetchDailyStatsForDate(let date):
            return "/dailyStat/\(date)"
        case .fetchDailyStatsForMonth(let yearMonth):
            return "/dailyStat/all/\(yearMonth)"
        case .getFriendDailyStats(let friendId, let yearMonth):
            return "/dailyStat/friend/\(friendId)/\(yearMonth)"
            
        case .searchUser(let query):
            return "/social/search/\(query)"
        case .getFriends:
            return "/social"
        case .requestFriend(let userId):
            return "/social/request/\(userId)"
        case .getPendingRequests:
            return "/social/requests/pending"
        case .acceptFriendRequest(let requestId):
            return "/social/accept/\(requestId)"
        case .removeFriend(let friendId):
            return "/social/\(friendId)"
            
        case .deleteAccount:
            return "/auth"
        }
    }
}
