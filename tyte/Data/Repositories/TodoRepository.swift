class TodoRepository: TodoRepositoryProtocol {
    private let remoteDataSource: TodoRemoteDataSource
    private let localDataSource: TodoLocalDataSource
    private let syncManager: SyncManagerProtocol
    
    init(
        remoteDataSource: TodoRemoteDataSource = TodoRemoteDataSource(),
        localDataSource: TodoLocalDataSource = TodoLocalDataSource(),
        syncManager: SyncManagerProtocol = SyncManager.shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncManager = syncManager
    }
    
    func get(in date: String) async throws -> [Todo] {
        if NetworkManager.shared.isConnected {
            do {
                let remoteTodos = try await remoteDataSource.fetchTodos(in: date)
                try localDataSource.saveTodos(remoteTodos)
                return remoteTodos
            } catch {
                return try localDataSource.getTodos(for: date)
            }
        } else {
            return try localDataSource.getTodos(for: date)
        }
    }
    
    func get(in date: String, for id: String) async throws -> [Todo] {
        return try await remoteDataSource.fetchTodos(in: date, for: id)
    }
    
    func create(text: String, in date: String) async throws -> [Todo] {
        let todos = try await remoteDataSource.createTodo(text: text, in: date)
        try localDataSource.saveTodos(todos)
        
        return todos
    }
    
    func updateSingle(_ todo: Todo) async throws {
        if NetworkManager.shared.isConnected {
            _ = try await remoteDataSource.updateTodo(todo)
            try localDataSource.saveTodo(todo)
        } else {
            try localDataSource.saveTodo(todo)
            syncManager.enqueueOperation(.updateTodo(todo))
        }
    }
    
    func deleteSingle(_ id: String) async throws {
        if NetworkManager.shared.isConnected {
            _ = try await remoteDataSource.deleteTodo(id)
            try localDataSource.deleteTodo(id)
        } else {
            try localDataSource.deleteTodo(id)
            syncManager.enqueueOperation(.deleteTodo(id))
        }
    }
    
    func toggleSingle(_ id: String) async throws {
        let toggledTodo = try await remoteDataSource.toggleTodo(id)
        try localDataSource.saveTodo(toggledTodo)
    }
    
    /// ``TagUseCase``에서 Tag와 연결된 Todo배열 접근 위해 접근
    func getWithTag(id: String) async throws -> [Todo] {
        let allTodos = try localDataSource.getAllTodos()
        return allTodos.filter { $0.tag?.id == id }
    }
}
