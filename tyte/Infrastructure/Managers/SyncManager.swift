import Foundation
import Combine

protocol SyncManagerProtocol {
    func enqueueOperation(_ type: SyncOperationType)
    func startSync()
    func stopSync()
}

class SyncManager: SyncManagerProtocol {
    private let coreDataStack: CoreDataStack
    
    private let todoService: TodoServiceProtocol
    private let tagService: TagServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 30  // 30초마다 동기화 시도
    private let maxRetries = 3
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = SyncManager()
    
    private init(
        coreDataStack: CoreDataStack = .shared,
        todoService: TodoServiceProtocol = TodoService(),
        tagService: TagServiceProtocol = TagService(),
        dailyStatService: DailyStatServiceProtocol = DailyStatService()
    ) {
        self.coreDataStack = coreDataStack
        self.todoService = todoService
        self.tagService = tagService
        self.dailyStatService = dailyStatService
        
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        NetworkManager.shared.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.startSync()
                } else {
                    self?.stopSync()
                }
            }
            .store(in: &cancellables)
    }
    
    func startSync() {
        stopSync()  // 기존 타이머 중지
        processPendingOperations()
        
        // 주기적으로 실행할 타이머 설정
        syncTimer = Timer.scheduledTimer(
            withTimeInterval: syncInterval,
            repeats: true
        ) { [weak self] _ in
            self?.processPendingOperations()
        }
    }
    
    func stopSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    func enqueueOperation(_ type: SyncOperationType) {
        let operation = SyncOperation(type: type)
        
        do {
            try coreDataStack.performInTransaction {
                let entity = SyncOperationEntity(context: coreDataStack.context)
                entity.id = operation.id
                entity.payload = try JSONEncoder().encode(operation)
                entity.createdAt = operation.createdAt
                entity.status = operation.status.rawValue
                // retryCount
                // lastAttempt
                // errorMessage
            }
        } catch {
            print("Failed to save sync operation: \(error)")
        }
    }
    
    private func processPendingOperations() {
        guard NetworkManager.shared.isConnected else { return }
        
        do {
            let request = SyncOperationEntity.fetchRequest()
            request.predicate = NSPredicate(format: "status == %@", SyncStatus.pending.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            
            let operations = try coreDataStack.context.fetch(request)
            
            for entity in operations {
                guard let data = entity.payload,
                      let operation = try? JSONDecoder().decode(SyncOperation.self, from: data)
                else { continue }
                
                // 재시도 횟수 초과 확인
                if operation.retryCount >= maxRetries {
                    updateCommandStatus(entity, to: .maxRetriesExceeded)
                    continue
                }
                
                // 작업 실행
                Task {
                    do {
                        try await processOperation(operation)
                        updateCommandStatus(entity, to: .completed)
                    } catch {
                        var updatedOperation = operation
                        updatedOperation.retryCount += 1
                        updatedOperation.lastAttempted = Date()
                        updatedOperation.errorMessage = error.localizedDescription
                        
                        if updatedOperation.retryCount >= maxRetries {
                            updateCommandStatus(entity, to: .maxRetriesExceeded)
                        } else {
                            try? updateOperation(entity, with: updatedOperation)
                        }
                    }
                }
            }
        } catch {
            print("Failed to process pending operations: \(error)")
        }
    }
    
    private func processOperation(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .updateTodo(let todo):
            _ = try await todoService.updateTodo(todo: todo)
        case .deleteTodo(let id):
            _ = try await todoService.deleteTodo(id: id)
        case .updateTag(let tag):
            _ = try await tagService.updateTag(tag: tag)
        case .deleteTag(let id):
            _ = try await tagService.deleteTag(id: id)
        }
    
    }
    
    private func updateCommandStatus(_ entity: SyncOperationEntity, to status: SyncStatus) {
        do {
            try coreDataStack.performInTransaction {
                entity.status = status.rawValue
            }
        } catch {
            print("Failed to update operation status: \(error)")
        }
    }
    
    private func updateOperation(_ entity: SyncOperationEntity, with operation: SyncOperation) throws {
        try coreDataStack.performInTransaction {
            entity.payload = try JSONEncoder().encode(operation)
            entity.status = operation.status.rawValue
        }
    }
}
