class AuthRepository: AuthRepositoryProtocol {
    
    private let remoteDataSource: AuthRemoteDataSourceProtocol
    
    // MARK: - Initialization
    
    init(remoteDataSource: AuthRemoteDataSourceProtocol = AuthRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    // MARK: - Implementation
    
    func login(email: String, password: String) async throws -> LoginResponse {
        try await remoteDataSource.login(email: email, password: password)
    }
    
    func socialLogin(idToken: String, provider: String) async throws -> LoginResponse {
        try await remoteDataSource.socialLogin(idToken: idToken, provider: provider)
    }
    
    func signUp(email: String, username: String, password: String) async throws -> LoginResponse {
        try await remoteDataSource.signUp(email: email, username: username, password: password)
    }
    
    func validateToken(_ token: String) async throws -> ValidateResponse {
        try await remoteDataSource.validateToken(token)
    }
    
    func checkEmail(_ email: String) async throws -> ValidateResponse {
        try await remoteDataSource.checkEmail(email)
    }
    
    func deleteAccount() async throws {
        try await remoteDataSource.deleteAccount()
    }
    
    func checkVersion() async throws -> VersionResponse {
        try await remoteDataSource.checkVersion()
    }
}
