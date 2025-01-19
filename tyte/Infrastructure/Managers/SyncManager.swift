import Foundation
import Combine

protocol SyncManagerProtocol {
    func enqueueOperation(_ type: SyncOperationType)
    func startSync()
    func stopSync()
}

/// 앱의 데이터 동기화를 관리하는 싱글톤 클래스입니다.
///
/// 다음과 같은 동기화 기능을 제공합니다:
/// - 오프라인 작업 큐잉
/// - 네트워크 재연결 시 자동 동기화
/// - 재시도 정책 관리
///
/// ## 사용 예시
/// ```swift
/// // 오프라인 상태에서 작업 큐잉
/// SyncManager.shared.enqueueOperation(
///     .updateTodo(modifiedTodo)
/// )
///
/// // 수동으로 동기화 시작
/// SyncManager.shared.startSync()
/// ```
///
/// ## 관련 타입
/// - ``SyncOperation``
/// - ``SyncStatus``
/// - ``NetworkManager``
///
/// - Note: 작업별로 최대 3회까지 재시도합니다.
/// - Important: 동기화는 30초 간격으로 자동 실행됩니다.
class SyncManager: SyncManagerProtocol {
    private let coreDataStack: CoreDataStack
    
    private let todoService: TodoRemoteDataSourceProtocol
    private let tagService: TagRemoteDataSourceProtocol
    
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 30
    private let maxRetries = 3
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = SyncManager()
    
    private init(
        coreDataStack: CoreDataStack = .shared,
        todoService: TodoRemoteDataSourceProtocol = TodoRemoteDataSource(),
        tagService: TagRemoteDataSourceProtocol = TagRemoteDataSource()
    ) {
        self.coreDataStack = coreDataStack
        self.todoService = todoService
        self.tagService = tagService
        
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
        stopSync()
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval,repeats: true) { [weak self] _ in
            self?.processPendingOperations()
        }
        processPendingOperations()
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
                
                if operation.retryCount >= maxRetries {
                    updateCommandStatus(entity, to: .maxRetriesExceeded)
                    continue
                }
                
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
            _ = try await todoService.updateTodo(todo)
        case .deleteTodo(let id):
            _ = try await todoService.deleteTodo(id)
        case .updateTag(let tag):
            _ = try await tagService.updateTag(tag)
        case .deleteTag(let id):
            _ = try await tagService.deleteTag(id)
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
