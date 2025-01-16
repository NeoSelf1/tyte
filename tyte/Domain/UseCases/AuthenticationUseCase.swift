//AuthenticationUseCase → AuthRepository → AuthRemoteDataSource → NetworkService

protocol AuthenticationUseCaseProtocol {
    func login(email: String, password: String) async throws -> User
    func socialLogin(idToken: String, provider: String) async throws -> User
    func signUp(email: String, username: String, password: String) async throws -> User
    func validateToken(_ token: String) async throws -> Bool
    func checkEmail(_ email: String) async throws -> Bool
    func deleteAccount() async throws
    func checkVersion() async throws -> (newVersion: String, minVersion: String)
}

class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    // MARK: - Dependencies
    
    private let repository: AuthRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> User {
        let response = try await repository.login(email: email, password: password)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func socialLogin(idToken: String, provider: String) async throws -> User {
        let response = try await repository.socialLogin(idToken: idToken, provider: provider)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func signUp(email: String, username: String, password: String) async throws -> User {
        let response = try await repository.signUp(email: email, username: username, password: password)
        handleSuccessfulAuth(response)
        return response.user
    }
    
    func validateToken(_ token: String) async throws -> Bool {
        let response = try await repository.validateToken(token)
        return response.isValid
    }
    
    func checkEmail(_ email: String) async throws -> Bool {
        let response = try await repository.checkEmail(email)
        return response.isValid
    }
    
    func deleteAccount() async throws {
        try await repository.deleteAccount()
        UserDefaultsManager.shared.logout()
    }
    
    func checkVersion() async throws -> (newVersion: String, minVersion: String) {
        let response = try await repository.checkVersion()
        return (newVersion: response.newVersion, minVersion: response.minVersion)
    }
    
    // MARK: - Private Methods
    
    private func handleSuccessfulAuth(_ response: LoginResponse) {
        KeychainManager.shared.saveToken(response.token)
        UserDefaultsManager.shared.login(response.user.id)
    }
}
