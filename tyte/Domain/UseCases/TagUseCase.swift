enum TagError: Error {
    case duplicateName
    case invalidColorFormat
}

protocol TagUseCaseProtocol {
    func getAllTags() async throws -> [Tag]
    func createTag(name: String, color: String) async throws -> Tag
    func updateTag(_ tag: Tag) async throws
    func deleteTag(_ id: String) async throws
}

/// 태그 관리 기능을 처리하는 Use Case입니다.
///
/// 다음과 같은 태그 관련 기능을 제공합니다:
/// - 태그 생성, 수정, 삭제, 조회
/// - 태그 중복 검사
/// - 연관된 Todo 항목 업데이트 처리
///
/// ## 사용 예시
/// ```swift
/// let tagUseCase = TagUseCase()
///
/// // 새 태그 생성
/// let newTag = try await tagUseCase.createTag(
///     name: "업무",
///     color: "FF0000"
/// )
///
/// // 태그 수정 시 연관 Todo 자동 업데이트
/// try await tagUseCase.updateTag(modifiedTag)
/// ```
///
/// ## 관련 타입
/// - ``TagRepository``
/// - ``TodoRepository``
/// - ``Tag``
///
/// - Note: 태그 수정/삭제 시 연관된 Todo 항목들이 자동으로 업데이트됩니다.
/// - Warning: 태그 이름은 중복될 수 없습니다.
/// - SeeAlso: ``TodoUseCase``
class TagUseCase: TagUseCaseProtocol {
    private let tagRepository: TagRepositoryProtocol
    private let todoRepository: TodoRepositoryProtocol
    
    init(
        tagRepository: TagRepositoryProtocol = TagRepository(),
        todoRepository: TodoRepositoryProtocol = TodoRepository()
    ) {
        self.tagRepository = tagRepository
        self.todoRepository = todoRepository
    }
    func getAllTags() async throws -> [Tag] {
        let tags = try await tagRepository.get()
        return tags
    }
    
    func createTag(name: String, color: String) async throws -> Tag {
        let existingTags = try await tagRepository.get()
        guard !existingTags.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw TagError.duplicateName
        }
        
        return try await tagRepository.createSingle(name: name, color: color)
    }
    
    /// - Note: 중복 명칭 태그 추출 로직은 경고 모달 표시를 담당하는 ViewModel에서 검증합니다.
    func updateTag(_ tag: Tag) async throws {
        try await tagRepository.updateSingle(tag)
        
        try await updateRelatedLocalTodos(to: tag)
    }
    
    func deleteTag(_ id: String) async throws {
        try await removeTagFromLocalTodos(tagId: id)
        
        _ = try await tagRepository.deleteSingle(id)
    }
}

private extension TagUseCase {
    private func updateRelatedLocalTodos(to tag: Tag) async throws {
        let allTodos = try await todoRepository.getWithTag(id:tag.id)
        for var todo in allTodos {
            todo.tag = tag
            _ = try await todoRepository.updateSingle(todo)
        }
    }
    
    private func removeTagFromLocalTodos(tagId: String) async throws {
        let affectedTodos = try await todoRepository.getWithTag(id: tagId)
        for var todo in affectedTodos {
            todo.tag = nil
            _ = try await todoRepository.updateSingle(todo)
        }
    }
}
