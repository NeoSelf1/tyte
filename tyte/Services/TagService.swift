import Foundation
import Combine
/// TagService는 할 일 태그(Tag) 관련 네트워크 요청을 처리하는 서비스입니다.
/// 태그의 생성, 조회, 수정, 삭제 기능을 제공하며, 할 일 분류와 관리를 위한 태그 시스템을 지원합니다.
class TagService: TagServiceProtocol {
    /// 네트워크 요청을 처리하는 서비스
    private let networkService: NetworkServiceProtocol
    
    /// TagService 초기화
    /// - Parameter networkService: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// 사용자의 모든 태그 목록을 조회합니다.
    /// - Returns: 태그 목록 정보를 포함한 Publisher
    /// - Note: 반환되는 TagsResponse에는 사용자가 생성한 모든 태그 정보가 포함됩니다.
    func fetchTags() -> AnyPublisher<TagsResponse, APIError> {
        return networkService.request(.fetchTags, method: .get, parameters: nil)
    }
    
    /// 새로운 태그를 생성합니다.
    /// - Parameters:
    ///   - name: 생성할 태그의 이름
    ///   - color: 태그의 색상 (hex 코드 형식: "#RRGGBB")
    /// - Returns: 생성된 태그 정보를 포함한 Publisher
    func createTag(name: String, color: String) -> AnyPublisher<Tag, APIError> {
        let parameters: [String: Any] = ["name": name, "color": color]
        return networkService.request(.createTag, method: .post, parameters: parameters)
    }
    
    /// 기존 태그를 수정합니다.
    /// - Parameter tag: 수정할 내용이 반영된 Tag 객체
    /// - Returns: 수정된 태그 정보를 포함한 Publisher
    /// - Note: tag.dictionary를 통해 Tag 객체의 모든 필드가 서버로 전송됩니다.
    func updateTag(_ tag: Tag) -> AnyPublisher<Tag, APIError> {
        return networkService.request(.updateTag(tag.id), method: .put, parameters: tag.dictionary)
    }
    
    /// 태그를 삭제합니다.
    /// - Parameter id: 삭제할 태그의 ID
    /// - Returns: 삭제된 태그의 ID를 포함한 Publisher
    /// - Note: 태그 삭제 시 해당 태그를 사용하는 모든 할 일에서 태그 참조가 제거됩니다.
    func deleteTag(id: String) -> AnyPublisher<String, APIError> {
        return networkService.request(.deleteTag(id), method: .delete, parameters: nil)
    }
}
