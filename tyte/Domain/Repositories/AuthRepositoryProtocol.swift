protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse
    func validateToken(_ token: String) async throws -> ValidateResponse
    func checkEmail(_ email: String) async throws -> ValidateResponse
    func deleteAccount() async throws
    func checkVersion() async throws -> VersionResponse
}
