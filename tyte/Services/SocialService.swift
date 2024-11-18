import Foundation
import Combine
import Alamofire

class SocialService: SocialServiceProtocol {
    private let networkService: NetworkServiceProtocol
        
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getFriends() -> AnyPublisher<FriendsResponse, APIError> {
        return networkService.request(.getFriends, method: .get, parameters: nil)
    }
    
    func searchUsers(query: String) -> AnyPublisher<[SearchResult], APIError> {
        return networkService.request(.searchUser(query), method: .get, parameters: nil)
    }
    
    func requestFriend(userId: String) -> AnyPublisher<IdResponse, APIError> {
        return networkService.request(.requestFriend(userId), method: .post, parameters: nil)
    }
    
    func getPendingRequests() -> AnyPublisher<PendingRequestsResponse, APIError> {
        return networkService.request(.getPendingRequests, method: .get, parameters: nil)
    }
    
    func acceptFriendRequest(requestId: String) -> AnyPublisher<IdResponse, APIError> {
        return networkService.request(.acceptFriendRequest(requestId), method: .patch, parameters: nil)
    }
    
    func rejectFriendRequest(requestId: String) -> AnyPublisher<EmptyResponse, APIError> {
        return networkService.request(.rejectFriendRequest(requestId), method: .patch, parameters: nil)
    }
    
    func removeFriend(friendId: String) -> AnyPublisher<EmptyResponse, APIError> {
        return networkService.request(.removeFriend(friendId), method: .delete, parameters: nil)
    }
}
