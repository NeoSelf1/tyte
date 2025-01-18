/// API 응답 타입들을 정의하는 파일입니다.
/// 서버로부터 받는 다양한 응답 형식을 Swift 타입으로 매핑합니다.
///
/// ## 주요 응답 타입
/// ### 인증 관련
/// - ``EmptyResponse``: 응답 데이터가 필요 없는 API 호출에 사용 (ex: 로그아웃)
/// - ``LoginResponse``: 로그인/회원가입 성공 시 사용자 정보와 인증 토큰 반환
/// - ``ValidateResponse``: 토큰 유효성 또는 이메일 중복 검증 결과 반환
/// - ``VersionResponse``: 앱 최신 버전 및 필수 업데이트 기준 버전 정보 반환
///
/// ### Todo 관련
/// - ``TodoResponse``: 단일 Todo 조작(생성/수정/삭제) 결과 반환
/// - ``TodosResponse``: 다중 Todo 조회 결과 반환 (날짜별/사용자별)
///
/// ### 태그 관련
/// - ``IdResponse``: 태그 생성/수정/삭제 시 해당 태그의 ID 반환
/// - ``TagsResponse``: 전체 태그 목록 조회 결과 반환
///
/// ### 통계 관련
/// - ``DailyStatResponse``: 특정 날짜의 통계 데이터 반환
/// - ``MonthlyStatsResponse``: 월별 전체 통계 데이터 배열 반환
///
/// ### 소셜 관련
/// - ``SearchUsersResponse``: 사용자 검색 결과 목록 반환
/// - ``FriendsResponse``: 현재 친구 목록 반환
/// - ``PendingRequestsResponse``: 받은 친구 요청 목록 반환
///
/// - Important: 모든 ID 필드는 서버의 MongoDB ObjectId와 매핑됩니다.
/// - Note: API 호출로 반환받은 JSON 타입과의 변환을 지원하기 위해 모든 응답 타입은 `Codable` 프로토콜을 준수합니다.

struct EmptyResponse: Codable {
    init() {}
    init(from decoder: Decoder) throws {}
}

struct LoginResponse: Codable {
    let user: User
    let token: String
}

struct ValidateResponse: Codable {
    let isValid: Bool
}

struct VersionResponse: Codable {
    let newVersion: String
    let minVersion: String
}

// MARK: - Todo 관련 api 함수 응답값 타입

typealias TodoResponse = Todo

// 여러 Todo 조회 응답에 사용 (날짜별 조회 등)
typealias TodosResponse = [Todo]


// MARK: - Tag 관련 api 함수 응답값 타입
// Tag 생성/수정/삭제시 ID만 반환
struct IdResponse: Codable {
    let id: String
}

typealias TagResponse = Tag

// Tag 목록 조회
typealias TagsResponse = [Tag]


// MARK: - DailyStat 관련 api 함수 응답값 타입
// 단일 DailyStat 조회
typealias DailyStatResponse = DailyStat

// 월별 DailyStat 조회
typealias MonthlyStatResponse = [DailyStat]


// MARK: - Social 관련 api 함수 응답값 타입
// 유저 검색 결과
typealias SearchUsersResponse = [SearchResult]

// 친구 목록 조회
typealias FriendsResponse = [User]

// 받은 친구 요청 목록
typealias FriendRequestsResponse = [FriendRequest]
