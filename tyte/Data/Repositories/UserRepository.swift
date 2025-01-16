class UserRepository: UserRepositoryProtocol {
    
    private let remoteDataSource: UserRemoteDataSourceProtocol
    
    init(
        remoteDataSource: UserRemoteDataSource = UserRemoteDataSource()
    ) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getFriends(for date: String) async throws -> [User] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.getFriendUsers()
    }
    
    
    func search(query: String) async throws -> [SearchResult] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.searchUser(query: query)
    }
    
    func postFriendRequest(_ userId: String) async throws {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        _ = try await remoteDataSource.postFriendRequest(userId: userId)
    }
    
    func getPendingRequest() async throws -> [FriendRequest] {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        return try await remoteDataSource.getPendingRequest()
    }
    
    func acceptFriendRequest(_ id: String) async throws {
        guard NetworkManager.shared.isConnected else { throw APIError.networkError}
        _ = try await remoteDataSource.acceptFriendRequest(requestId: id)
    }
}
