struct EmptyResponse: Decodable {
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

// MARK: - Todo 관련 api 함수 응답값 타입
// 단일 Todo 생성/수정/삭제 응답에 사용
typealias TodoResponse = Todo

// 여러 Todo 조회 응답에 사용 (날짜별 조회 등)
typealias TodosResponse = [Todo]

// MARK: - Tag 관련 api 함수 응답값 타입
// Tag 생성/수정/삭제시 ID만 반환
struct TagIdResponse: Codable {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}
// Tag 목록 조회
typealias TagsResponse = [Tag]

// MARK: - DailyStat 관련 api 함수 응답값 타입
// 단일 DailyStat 조회
typealias DailyStatResponse = DailyStat

// 월별 DailyStat 조회
typealias MonthlyStatsResponse = [DailyStat]

// MARK: - Social 관련 api 함수 응답값 타입
// 유저 검색 결과
typealias SearchUsersResponse = [SearchResult]

// 친구 목록 조회
typealias FriendsResponse = [User]

// 받은 친구 요청 목록
typealias PendingRequestsResponse = [FriendRequest]

// 친구 요청/수락/거절 응답 (ID만 반환)
struct FriendRequestIdResponse: Codable {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}
