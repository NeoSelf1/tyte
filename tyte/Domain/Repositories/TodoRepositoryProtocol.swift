///데이터의 저장소 추상화 역할
///데이터를 어떻게 저장하고 가져올지에 대한 책임
///로컬/원격 저장소 동기화 처리
///순수한 CRUD 작업 수행

protocol TodoRepositoryProtocol {
    func get(for date: String) async throws -> [Todo]
    func getWithTag(id tagId: String) async throws -> [Todo]
    func create(text: String, in date: String) async throws -> [Todo]
    func updateSingle(_ todo: Todo) async throws
    func deleteSingle(_ id: String) async throws
    func toggleSingle(_ id: String) async throws
}
