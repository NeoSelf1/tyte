import Foundation

protocol UserUseCaseProtocol {
    func getFriends() async throws -> [User]
    func searchUsers(query: String) async throws -> [SearchResult]
    func requestFriend(userId: String) async throws
    func getPendingRequests() async throws -> [FriendRequest]
    func acceptFriendRequest(_ requestId: String) async throws
}

class UserUseCase: UserUseCaseProtocol {
    // MARK: - Dependencies
    
    private let userRepository: UserRepositoryProtocol
    
    // MARK: - Initialization
    
    init(
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.userRepository = userRepository
    }
    
    // MARK: - Social Features
    
    func getFriends() async throws -> [User] {
        return try await userRepository.getFriends(for: Date().apiFormat)
    }
    
    func searchUsers(query: String) async throws -> [SearchResult] {
        return try await userRepository.search(query: query)
    }
    
    func requestFriend(userId: String) async throws {
        try await userRepository.postFriendRequest(userId)
    }
    
    func getPendingRequests() async throws -> [FriendRequest] {
        return try await userRepository.getPendingRequest()
    }
    
    func acceptFriendRequest(_ requestId: String) async throws {
        try await userRepository.acceptFriendRequest(requestId)
    }
}
