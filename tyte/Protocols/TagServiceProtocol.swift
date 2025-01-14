/// 태그 관련 API 요청을 처리하는 프로토콜입니다.
/// 태그의 CRUD 작업을 담당합니다.
protocol TagServiceProtocol {
    /// 모든 태그 조회
    func fetchTags() async throws -> TagsResponse
    /// 새로운 태그 생성
    func createTag(name: String, color: String) async throws -> TagResponse
    /// 태그 정보 업데이트
    func updateTag(tag: Tag) async throws -> TagResponse
    /// 태그 삭제
    func deleteTag(id: String) async throws -> String
}
