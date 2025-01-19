protocol TodoRepositoryProtocol {
    func get(in date: String) async throws -> [Todo]
    func get(in date: String, for id: String) async throws -> [Todo]
    func getWithTag(id tagId: String) async throws -> [Todo]
    func create(text: String, in date: String) async throws -> [Todo]
    func updateSingle(_ todo: Todo) async throws
    func deleteSingle(_ id: String) async throws
    func toggleSingle(_ id: String) async throws
}
