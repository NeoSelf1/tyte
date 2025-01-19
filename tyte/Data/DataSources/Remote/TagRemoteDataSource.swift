protocol TagRemoteDataSourceProtocol {
    func fetchTags() async throws -> TagsResponse
    func createTag(name: String, color: String) async throws -> TagResponse
    func updateTag(_ tag: Tag) async throws -> TagResponse
    func deleteTag(_ id: String) async throws -> String
}

/// 태그 데이터에 대한 원격 데이터 접근을 담당하는 DataSource입니다.
///
/// 서버와의 통신을 통해 다음 기능을 제공합니다:
/// - 태그 CRUD 작업 처리
/// - 사용자별 태그 조회
///
/// ## 사용 예시
/// ```swift
/// let tagDataSource = TagRemoteDataSource()
///
/// // 태그 목록 조회
/// let tags = try await tagDataSource.fetchTags()
///
/// // 새 태그 생성
/// let newTag = try await tagDataSource.createTag(
///     name: "업무",
///     color: "FF0000"
/// )
/// ```
///
/// ## API Endpoints
/// - GET /tag: 태그 목록 조회
/// - POST /tag: 태그 생성
/// - PUT /tag/{id}: 태그 수정
/// - DELETE /tag/{id}: 태그 삭제
///
/// ## 관련 타입
/// - ``NetworkAPI``
/// - ``APIEndpoint``
/// - ``Tag``
///
/// - Note: 모든 요청은 인증이 필요합니다.
/// - SeeAlso: ``TagRepository``, ``APIEndpoint``
class TagRemoteDataSource: TagRemoteDataSourceProtocol {
    private let networkAPI: NetworkAPI
    
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    func fetchTags() async throws -> TagsResponse {
        return try await networkAPI.request(.fetchTags, method: .get, parameters: nil)
    }
    
    func createTag(name: String, color: String) async throws -> TagResponse {
        let parameters: [String: Any] = ["name": name, "color": color]
        return try await networkAPI.request(.createTag, method: .post, parameters: parameters)
    }
    
    func updateTag(_ tag: Tag) async throws -> TagResponse {
        return try await networkAPI.request(
            .updateTag(tag.id),
            method: .put,
            parameters: tag.dictionary
        )
    }
    
    func deleteTag(_ id: String) async throws -> String {
        return try await networkAPI.request(.deleteTag(id), method: .delete, parameters: nil)
    }
}
