protocol TagRemoteDataSourceProtocol {
    /// 모든 태그 조회
    func fetchTags() async throws -> TagsResponse
    /// 새로운 태그 생성
    func createTag(name: String, color: String) async throws -> TagResponse
    /// 태그 정보 업데이트
    func updateTag(_ tag: Tag) async throws -> TagResponse
    /// 태그 삭제
    func deleteTag(_ id: String) async throws -> String
}

/// TagService는 할 일 태그(Tag) 관련 네트워크 요청을 처리하는 서비스입니다.
/// 태그의 생성, 조회, 수정, 삭제 기능을 제공하며, 할 일 분류와 관리를 위한 태그 시스템을 지원합니다.
class TagRemoteDataSource: TagRemoteDataSourceProtocol {
    /// 네트워크 요청을 처리하는 서비스
    private let networkAPI: NetworkAPI
    
    /// TagService 초기화
    /// - Parameter NetworkAPI: 네트워크 요청을 처리할 서비스 인스턴스
    init(networkAPI: NetworkAPI = NetworkAPI()) {
        self.networkAPI = networkAPI
    }
    
    /// 사용자의 모든 태그 목록을 조회합니다.
    /// - Returns: 태그 목록 정보
    /// - Note: 반환되는 TagsResponse에는 사용자가 생성한 모든 태그 정보가 포함됩니다.
    func fetchTags() async throws -> TagsResponse {
        return try await networkAPI.request(.fetchTags, method: .get, parameters: nil)
    }
    
    /// 새로운 태그를 생성합니다.
    /// - Parameters:
    ///   - name: 생성할 태그의 이름
    ///   - color: 태그의 색상 (hex 코드 형식: "#RRGGBB")
    /// - Returns: 생성된 태그 정보
    func createTag(name: String, color: String) async throws -> TagResponse {
        let parameters: [String: Any] = ["name": name, "color": color]
        return try await networkAPI.request(.createTag, method: .post, parameters: parameters)
    }
    
    /// 기존 태그를 수정합니다.
    /// - Parameter tag: 수정할 내용이 반영된 Tag 객체
    /// - Returns: 수정된 태그 정보
    /// - Note: tag.dictionary를 통해 Tag 객체의 모든 필드가 서버로 전송됩니다.
    func updateTag(_ tag: Tag) async throws -> TagResponse {
        return try await networkAPI.request(
            .updateTag(tag.id),
            method: .put,
            parameters: tag.dictionary
        )
    }
    
    /// 태그를 삭제합니다.
    /// - Parameter id: 삭제할 태그의 ID
    /// - Returns: 삭제된 태그의 ID
    /// - Note: 태그 삭제 시 해당 태그를 사용하는 모든 할 일에서 태그 참조가 제거됩니다.
    func deleteTag(_ id: String) async throws -> String {
        return try await networkAPI.request(.deleteTag(id), method: .delete, parameters: nil)
    }
}
