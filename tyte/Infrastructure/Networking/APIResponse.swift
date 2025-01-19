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

typealias TodoResponse = Todo

typealias TodosResponse = [Todo]

struct IdResponse: Codable {
    let id: String
}

typealias TagResponse = Tag

typealias TagsResponse = [Tag]

typealias DailyStatResponse = DailyStat

typealias MonthlyStatResponse = [DailyStat]

typealias SearchUsersResponse = [SearchResult]

typealias FriendsResponse = [User]

typealias FriendRequestsResponse = [FriendRequest]
