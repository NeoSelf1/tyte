import Foundation
import Combine

class TagService {
    static let shared = TagService()
    private let apiManager = APIManager.shared
    
    func fetchAllTags() -> AnyPublisher<[Tag], APIError> {
        let endpoint = APIEndpoint.fetchTags
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[Tag], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func createTag(name: String, color: String) -> AnyPublisher<String, APIError> {
        let endpoint = APIEndpoint.createTag
        let parameters: [String: Any] = ["name": name, "color": color]
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .post, parameters: parameters) { (result: Result<String, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func updateTag(tag: Tag) -> AnyPublisher<String, APIError> {
        let endpoint = APIEndpoint.updateTag(tag.id)
        let parameters = tag.dictionary
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .put, parameters: parameters) { (result: Result<String, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteTag(id: String) -> AnyPublisher<String, APIError> {
        let endpoint = APIEndpoint.deleteTag(id)
        
        return Future { promise in
            self.apiManager.request(endpoint, method: .delete) { (result: Result<String, APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}
