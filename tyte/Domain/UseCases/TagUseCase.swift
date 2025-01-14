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
    private let repository: TagRepository
    
    init(repository: TagRepository) {
        self.repository = repository
    }
    
    func getAllTags() async throws -> [Tag] {
        return try await repository.get()
    }
    
    func createTag(name: String, color: String) async throws -> Tag {
        let existingTags = try await repository.get()
        guard !existingTags.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw TagError.duplicateName
        }
        
        return try await repository.createSingle(name: name, color: color)
    }
    
    func updateTag(_ tag: Tag) async throws -> Tag {
        // 태그 이름 중복 검사 (자기 자신 제외)
        let existingTags = try await repository.get()
        if let existingTag = existingTags.first(where: {
            $0.name.lowercased() == tag.name.lowercased() && $0.id != tag.id
        }) {
            throw TagError.duplicateName
        }
        
        return try await repository.updateSingle(tag)
    }
    
    func deleteTag(_ id: String) async throws {
        // 연관된 Todo가 있는지 확인하는 로직 등을 추가할 수 있음
        let _ = try await repository.deleteSingle(id)
    }
}
