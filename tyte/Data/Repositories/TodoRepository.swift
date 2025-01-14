class TodoRepository: TodoRepositoryProtocol {
    private let remoteDataSource: TodoRemoteDataSource
    private let localDataSource: TodoLocalDataSource
    private let syncManager: SyncManager
    
    init(
        remoteDataSource: TodoRemoteDataSource,
        localDataSource: TodoLocalDataSource,
        syncManager: SyncManager
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncManager = syncManager
    }
    
    func get(for date: String) async throws -> [Todo] {
        // 1. 로컬 데이터 먼저 반환
        let localTodos = try localDataSource.getTodos(for: date)
        
        // 2. 네트워크 연결 시 원격 데이터 동기화
        if NetworkManager.shared.isConnected {
            do {
                let remoteTodos = try await remoteDataSource.fetchTodos(for: date)
                try localDataSource.saveTodos(remoteTodos)
                return remoteTodos
            } catch {
                // 네트워크 오류 시 로컬 데이터 반환
                return localTodos
            }
        }
        
        return localTodos
    }
    
    func create(text: String, in date: String) async throws -> [Todo] {
        let todos = try await remoteDataSource.createTodo(text: text, in: date)
        try localDataSource.saveTodos(todos)
        return todos
    }
    
    func updateSingle(_ todo: Todo) async throws -> Todo {
        if !NetworkManager.shared.isConnected {
            // 오프라인 시 로컬 저장 후 동기화 큐에 추가
            try localDataSource.updateTodo(todo)
            syncManager.enqueueOperation(.updateTodo(todo))
            return todo
        }
        
        let updatedTodo = try await remoteDataSource.updateTodo(todo)
        try localDataSource.updateTodo(updatedTodo)
        return updatedTodo
    }
    
    func deleteSingle(_ id: String) async throws -> Todo {
        if !NetworkManager.shared.isConnected {
            try localDataSource.deleteTodo(id)
            syncManager.enqueueOperation(.deleteTodo(id))
            // 오프라인 삭제 시 임시 Todo 반환
            return Todo(id: id, raw: "", title: "", isImportant: false, isLife: false,
                       difficulty: 0, estimatedTime: 0, deadline: "", isCompleted: false,
                       userId: "", createdAt: "")
        }
        
        let deletedTodo = try await remoteDataSource.deleteTodo(id)
        try localDataSource.deleteTodo(id)
        return deletedTodo
    }
    
    func toggleSingle(_ id: String) async throws -> Todo {
        let toggledTodo = try await remoteDataSource.toggleTodo(id)
        try localDataSource.updateTodo(toggledTodo)
        return toggledTodo
    }
}
