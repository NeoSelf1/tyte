import Foundation
import Combine

class TagService: TagServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchTags() -> AnyPublisher<TagsResponse, APIError> {
        return networkService.request(.fetchTags, method: .get, parameters: nil)
    }
    
    func createTag(name: String, color: String) -> AnyPublisher<Tag, APIError> {
        let parameters: [String: Any] = ["name": name, "color": color]
        return networkService.request( .createTag, method: .post, parameters: parameters)
    }
    
    func updateTag(_ tag: Tag) -> AnyPublisher<Tag, APIError> {
        return networkService.request( .updateTag(tag.id), method: .put, parameters: tag.dictionary)
    }
    
    func deleteTag(id: String) -> AnyPublisher<String, APIError> {
        return networkService.request( .deleteTag(id), method: .delete, parameters: nil)
    }
}
