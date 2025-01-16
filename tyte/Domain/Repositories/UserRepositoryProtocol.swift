protocol UserRepositoryProtocol {
    func getFriends(for date: String) async throws -> [User]
    func search(query: String) async throws -> [SearchResult]
    func postFriendRequest(_ userId: String) async throws
    func getPendingRequest() async throws -> [FriendRequest]
    func acceptFriendRequest(_ id: String) async throws
}
