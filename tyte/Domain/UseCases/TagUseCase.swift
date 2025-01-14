/// UseCase는 비즈니스 로직 실행에 집중해야 하며, 상태관리는 ViewModel 계층의 책임으로 합니다.
/// 여러 곳에서 UseCase 사용 시 상태 일관성 보장 어려움
///
/// 선언적 프로그래밍의 이점과 유사하다고 느꼈음 -> 어떻게 구현하는지를 Repository로 분리 및 추상화하여, 어떤 순서로 로직이 조합되어야 하는지에 집중할 수 있음
///  ex. Tag를 수정하여도, RelationShip 관계에 있는 다른 CoreData Entity에 대한 연쇄 수정이 동반되어야하는 경우 발생하는데, 이를 Repository로 접근해 쉽게 구현
///  - Note:로컬과 리모트 환경 두 상황을 모두 해결하려다 보니까 이러한 경험이 더 극대화 되는 것 같음.
enum TagError: Error {
    case duplicateName
    case invalidColorFormat
}

protocol TagUseCaseProtocol {
    func getAllTags() async throws -> [Tag]
    func createTag(name: String, color: String) async throws -> Tag
    func updateTag(_ tag: Tag) async throws -> Tag
    func deleteTag(_ id: String) async throws
}

class TagUseCase: TagUseCaseProtocol {
    private let tagRepository: TagRepositoryProtocol
    private let todoRepository: TodoRepositoryProtocol
    
    init(
        tagRepository: TagRepositoryProtocol,
        todoRepository: TodoRepositoryProtocol
    ) {
        self.tagRepository = tagRepository
        self.todoRepository = todoRepository
    }
    /// 모든 최신 태그들을 네트워크 상황과 상관없이 가져오고, UseCase 내부에서 이를 저장해 관리합니다.
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
    
    func updateTag(_ tag: Tag) async throws -> Tag {
        let existingTags = try await tagRepository.get()
        if let existingTag = existingTags.first(where: {
            $0.name.lowercased() == tag.name.lowercased() && $0.id != tag.id
        }) {
            throw TagError.duplicateName
        }
        
        let updatedTag = try await tagRepository.updateSingle(tag)
        try await updateRelatedLocalTodos(to: updatedTag)
        
        return updatedTag
    }
    
    func deleteTag(_ id: String) async throws {
        try await removeTagFromLocalTodos(tagId: id)
        
        let _ = try await tagRepository.deleteSingle(id)
    }
}


private extension TagUseCase {
    private func updateRelatedLocalTodos(to tag: Tag) async throws {
        let allTodos = try await todoRepository.getWithTag(id:tag.id)
        for var todo in allTodos {
            todo.tag = tag  // 태그 정보 업데이트
            _ = try await todoRepository.updateSingle(todo)
        }
    }
    
    private func removeTagFromLocalTodos(tagId: String) async throws {
        let affectedTodos = try await todoRepository.getWithTag(id: tagId)
        for var todo in affectedTodos {
            todo.tag = nil  // 태그 참조 제거
            _ = try await todoRepository.updateSingle(todo)
        }
    }
}
