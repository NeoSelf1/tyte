import Combine
/// 태그 관련 API 요청을 처리하는 프로토콜입니다.
/// 태그의 CRUD 작업을 담당합니다.

protocol TagServiceProtocol {
    /// 모든 태그 조회
    func fetchTags() -> AnyPublisher<TagsResponse, APIError>
    /// 새로운 태그 생성
    func createTag(name: String, color: String) -> AnyPublisher<Tag, APIError>
    /// 태그 정보 업데이트
    func updateTag(_ tag: Tag) -> AnyPublisher<Tag, APIError>
    /// 태그 삭제
    func deleteTag(id: String) -> AnyPublisher<String, APIError>
}
