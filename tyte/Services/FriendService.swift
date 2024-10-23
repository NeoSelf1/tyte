import Foundation
import Combine
import Alamofire

class FriendService {
    static let shared = FriendService()
    private let apiManager = APIManager.shared
    
    func getFriends(searchQuery: String = "") -> AnyPublisher<[User], APIError> {
        let endpoint = APIEndpoint.getFriends
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[User], APIError>) in
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
}
