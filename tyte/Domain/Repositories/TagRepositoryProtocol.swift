protocol TagRepositoryProtocol {
    func get() async throws -> [Tag]
    func createSingle(name: String, color: String) async throws -> Tag
    func updateSingle(_ tag: Tag) async throws -> Tag
    func deleteSingle(_ id: String) async throws -> String
}
