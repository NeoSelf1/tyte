import Foundation
import Combine
import Alamofire

class SocialService {
    static let shared = SocialService()
    private let apiManager = APIManager.shared
    
    func getFriends(searchQuery: String = "") -> AnyPublisher<[User], APIError> {
        let endpoint = APIEndpoint.getFriends
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[User], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func requestFriend(userId: String) -> AnyPublisher<String,APIError> {
        let endpoint = APIEndpoint.requestFriend(userId)
        
        return Future { promise in
            self.apiManager.request(endpoint,method: .post) { (result: Result<String, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
        
    }
    
    func searchUser(searchQuery: String = "") -> AnyPublisher<[SearchResult], APIError> {
        let endpoint = APIEndpoint.searchUser(searchQuery)
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[SearchResult], APIError>) in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getFriendDailyStats(friendId: String, range: String) -> AnyPublisher<[DailyStat], APIError> {
        let endpoint = APIEndpoint.getFriendDailyStats(friendId: friendId, range: range)
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[DailyStat], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func getPendingRequests() -> AnyPublisher<[FriendRequest], APIError> {
        let endpoint = APIEndpoint.getPendingRequests
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[FriendRequest], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func acceptFriendRequest(requestId: String) -> AnyPublisher<String, APIError> {
        let endpoint = APIEndpoint.acceptFriendRequest(requestId)
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .patch) { (result: Result<String, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}
