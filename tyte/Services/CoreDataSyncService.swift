import Combine
import CoreData
import Foundation
import Network
/// CoreDataSyncService는 앱의 오프라인 동기화를 관리하는 메인 서비스입니다.
/// 이 서비스는 CoreData를 사용한 로컬 저장소와 서버 간의 데이터 동기화를 처리하며,
/// 네트워크 연결이 불안정하거나 없는 상황에서도 앱이 정상적으로 작동할 수 있도록 합니다.
///
/// 주요 기능:
/// - 로컬 저장소(CoreData)와 서버 간의 데이터 동기화
/// - 오프라인 상태에서의 작업 큐 관리
/// - 네트워크 상태 모니터링 및 자동 동기화
/// - 데이터 무결성 보장을 위한 트랜잭션 처리
///
/// 동기화 대상 도메인:
/// - Todo: 사용자의 할일 관리
/// - Tag: Todo에 연결되는 태그
/// - DailyStat: 날짜별 통계 데이터
///
/// - Note:save는 create와 update를 모두 수행할 수 있음을 의미합니다.
/// - Warning:SRP를 준수하지 않고 있으며, 도메인 별 파일 분리 및 의존성 역전이 필요합니다.
enum SyncOperationType: Codable {
    case updateTodo(Todo)
    case deleteTodo(String)
    
    case updateTag(Tag)
    case deleteTag(String)
}

enum SyncStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case failed
}

/// SyncOperation은 동기화해야 할 작업을 정의하는 구조체입니다.
/// - 작업 타입과 타임스탬프를 포함합니다.
struct SyncOperation: Codable {
    let type: SyncOperationType
    let timestamp: Date
    
    static func create(type: SyncOperationType) -> SyncOperation {
        SyncOperation(
            type: type,
            timestamp: Date()
        )
    }
}

/// SyncCommand는 동기화 작업의 실행 상태를 추적하는 구조체입니다.
/// - 작업 ID, 작업 내용, 상태, 재시도 횟수 등을 포함합니다.
struct SyncCommand: Codable {
    let id: UUID
    let operation: SyncOperation
    var status: SyncStatus
    var retryCount: Int
    var lastAttempt: Date?
    var errorMessage: String?
}


class CoreDataSyncService {
    // MARK: - Properties
    
    /// 싱글톤 인스턴스
    static let shared = CoreDataSyncService()
    
    /// CoreData 스택 인스턴스
    private let coreDataStack: CoreDataStack = .shared
    /// 위젯 업데이트 매니저
    private let widgetManager: WidgetManager = .shared
    
    /// 도메인별 서비스 인스턴스들
    private let todoService: TodoServiceProtocol
    private let tagService: TagServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    
    /// 오프라인 작업 큐
    private let syncQueue = SyncQueue()
    
    /// Combine 구독 저장소
    private var cancellables = Set<AnyCancellable>()
    
    /// CoreDataSyncService 초기화
    /// - Parameters:
    ///   - todoService: Todo 관련 네트워크 요청을 처리하는 서비스
    ///   - tagService: Tag 관련 네트워크 요청을 처리하는 서비스
    ///   - dailyStatService: DailyStat 관련 네트워크 요청을 처리하는 서비스
    init (
        todoService: TodoServiceProtocol = TodoService(),
        tagService: TagServiceProtocol = TagService(),
        dailyStatService: DailyStatServiceProtocol = DailyStatService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
        self.dailyStatService = dailyStatService
        
        setupNetworkMonitoring()
    }
    
    
    // MARK: - Core Methods
    
    /// 네트워크 상태 모니터링을 설정하고 상태 변화에 따라 동기화를 시작하거나 중지합니다.
    func setupNetworkMonitoring() {
        NetworkManager.shared.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.syncQueue.startSync()
                } else {
                    self?.syncQueue.stopSync()
                }
            }
            .store(in: &cancellables)
    }
    
    /// 로컬 저장소 업데이트 후 네트워크 동기화를 수행하는 메서드입니다.
    /// 오프라인일 경우 작업을 큐에 저장합니다.
    /// - Parameter operation: 수행할 동기화 작업
    /// - Returns: 작업 결과를 담은 Publisher
    func performSync(_ operation: SyncOperation) -> AnyPublisher<Any, Error> {
        /// 1. CoreData로 영구저장소에 변경사항 먼저 반영
        do {
            switch operation.type {
            case .updateTodo(let todo):
                try saveTodoToStore(todo)
                
                widgetManager.updateWidget(.todoList)
            case .deleteTodo(let id):
                try deleteTodoToStore(id)
                
                widgetManager.updateWidget(.todoList)
            case .updateTag(let tag):
                try saveTagToStore(tag)
            case .deleteTag(let id):
                try deleteTagToStore(id)
            }
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        /// 2. SyncCommand 생성 및 SyncQueue로 처리 요청
        return syncQueue.process(SyncCommand(
            id: UUID(),
            operation: operation,
            status: .pending,
            retryCount: 0
        ))
        .eraseToAnyPublisher()
    }
}


// MARK: - CRUD 연산들

extension CoreDataSyncService {
    
    /// 새로운 Todo를 생성합니다.
    /// 네트워크 연결이 필요한 작업으로, 오프라인에서는 수행할 수 없습니다.
    /// - Parameters:
    ///   - text: Todo 내용
    ///   - date: Todo 날짜
    /// - Returns: 생성된 Todo 배열을 포함한 Publisher
    func createTodo(text: String, in date: String) -> AnyPublisher<[Todo], Error> {
        return todoService.createTodo(text: text, in: date)
            .tryMap { [weak self] todos in
                try self?.saveTodosToStore(todos)
                
                self?.widgetManager.updateWidget(.todoList)
                return todos
            }
            .eraseToAnyPublisher()
    }
    ///
    /// Todo를 업데이트합니다.
    /// 오프라인에서도 작업이 가능하며, 네트워크 연결 시 자동으로 동기화됩니다.
    /// - Parameter todo: 업데이트할 Todo 객체
    /// - Returns: 업데이트된 Todo를 포함한 Publisher
    func updateTodo(_ todo: Todo) -> AnyPublisher<Todo, Error> {
        performSync(.create(type: .updateTodo(todo)))
            .map { $0 as! Todo }
            .eraseToAnyPublisher()
    }
    
    /// Todo를 삭제합니다.
    /// 오프라인에서도 작업이 가능하며, 네트워크 연결 시 자동으로 동기화됩니다.
    /// - Parameter id: 삭제할 Todo의 ID
    /// - Returns: 삭제된 Todo의 ID를 포함한 Publisher
    func deleteTodo(_ id: String) -> AnyPublisher<String, Error> {
        performSync(.create(type: .deleteTodo(id)))
            .map { $0 as! String } // deletedTodoId
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Tag domain
    
    func createTag(name: String, color: String) -> AnyPublisher<Tag, Error> {
        return tagService.createTag(name: name, color: color)
            .tryMap { [weak self] createdTag in
                try self?.saveTagToStore(createdTag)
                return createdTag
            }
            .eraseToAnyPublisher()
    }
    
    func updateTag(_ tag: Tag) -> AnyPublisher<Tag, Error> {
        performSync(.create(type: .updateTag(tag)))
            .map { $0 as! Tag }
            .eraseToAnyPublisher()
    }
    
    func deleteTag(_ id: String) -> AnyPublisher<String, Error> {
        performSync(.create(type: .deleteTag(id)))
            .map { $0 as! String }
            .eraseToAnyPublisher()
    }
}


// MARK: - Refresh 연산들

extension CoreDataSyncService {
/// 서버로부터 최신 Tag 목록을 가져와 로컬 저장소를 업데이트합니다.
   /// - Returns: 업데이트된 Tag 배열을 포함한 Publisher
   func refreshTags() -> AnyPublisher<[Tag], Error> {
        return tagService.fetchTags()
            .tryMap { [weak self] tags in
                try self?.saveTagsToStore(tags)
                return tags
            }
            .eraseToAnyPublisher()
    }
    
    /// 특정 날짜의 DailyStat을 서버로부터 가져와 로컬 저장소를 업데이트합니다.
    /// - Parameter date: 조회할 날짜
    /// - Returns: 업데이트된 DailyStat을 포함한 Publisher
    func refreshDailyStat(for date: String) -> AnyPublisher<DailyStat?, Error> {
        return dailyStatService.fetchDailyStat(for: date)
            .tryMap { [weak self] _dailyStat in
                if let dailyStat = _dailyStat{
                    try self?.saveDailyStatToStore(dailyStat)
                    self?.widgetManager.updateWidget(.calendar)
                }
                return _dailyStat
            }
            .eraseToAnyPublisher()
    }
    
    /// 특정 연월의 DailyStat 목록을 서버로부터 가져와 로컬 저장소를 업데이트합니다.
    /// - Parameter yearMonth: 조회할 연월(YYYY-MM 형식)
    /// - Returns: 업데이트된 DailyStat 배열을 포함한 Publisher
    func refreshDailyStats(for yearMonth: String) -> AnyPublisher<[DailyStat], Error> {
        return dailyStatService.fetchMonthlyStats(in: yearMonth)
            .tryMap { [weak self] dailyStats in
                try self?.saveDailyStatsToStore(dailyStats)
                self?.widgetManager.updateWidget(.calendar)
                return dailyStats
            }
            .eraseToAnyPublisher()
    }
    
    /// 특정 날짜의 Todo 목록을 서버로부터 가져와 로컬 저장소를 업데이트합니다.
    /// - Parameter date: 조회할 날짜
    /// - Returns: 업데이트된 Todo 배열을 포함한 Publisher
    func refreshTodos(for date: String) -> AnyPublisher<[Todo], Error> {
        return todoService.fetchTodos(for: date)
            .tryMap { [weak self] todos in
                try self?.saveTodosToStore(todos)
                return todos
            }
            .eraseToAnyPublisher()
    }
}


// MARK: - Local Storage Operations

extension CoreDataSyncService {
    /// 로컬 저장소에서 특정 날짜의 Todo 목록을 가져옵니다.
    /// - Parameter date: 조회할 날짜
    /// - Returns: Todo 배열
    /// - Throws: CoreData 관련 에러
    func readTodosFromStore(for date: String) throws -> [Todo] {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deadline == %@", date)
        request.sortDescriptors = [
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let todoEntities = try coreDataStack.context.fetch(request)
        
        let todos = todoEntities.map { entity in
            return Todo(
                id: entity.id ?? "",
                raw: entity.raw ?? "",
                title: entity.title ?? "",
                isImportant: entity.isImportant,
                isLife: entity.isLife,
                tag: entity.tag?.toDomain(),
                difficulty: Int(entity.difficulty),
                estimatedTime: Int(entity.estimatedTime),
                deadline: entity.deadline ?? "",
                isCompleted: entity.isCompleted,
                userId: entity.userId ?? "",
                createdAt: entity.createdAt ?? ""
            )
        }
        return todos
    }
    
    /// 로컬 저장소에서 특정 연월의 DailyStat 목록을 가져옵니다.
    /// - Parameter yearMonth: 조회할 연월(YYYY-MM 형식)
    /// - Returns: DailyStat 배열
    /// - Throws: CoreData 관련 에러
    func readDailyStatsFromStore(for yearMonth: String) throws -> [DailyStat] {
        let request = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date BEGINSWITH %@", yearMonth)
        let statEntities = try coreDataStack.context.fetch(request)
        return statEntities.map { entity in
            // TagStats 변환 로직
            let tagStats: [TagStat] = (entity.tagStats as? Set<TagStatEntity>)?.map { tagStatEntity in
                TagStat(
                    id: tagStatEntity.id ?? "",
                    tag: Tag(
                        id: tagStatEntity.tag?.id ?? "",
                        name: tagStatEntity.tag?.name ?? "",
                        color: tagStatEntity.tag?.color ?? "",
                        userId: tagStatEntity.tag?.userId ?? ""
                    ),
                    count: Int(tagStatEntity.count)
                )
            } ?? []
            
            return DailyStat(
                id: entity.id ?? "",
                date: entity.date ?? "",
                userId: entity.userId ?? "",
                balanceData: BalanceData(
                    title: entity.balanceTitle ?? "",
                    message: entity.balanceMessage ?? "",
                    balanceNum: Int(entity.balanceNum)
                ),
                productivityNum: entity.productivityNum,
                tagStats: tagStats,
                center: SIMD2<Float>(entity.centerX, entity.centerY)
            )
        }
    }
    
    /// 로컬 저장소에서 현재 사용자의 모든 Tag를 가져옵니다.
    /// - Returns: Tag 배열
    /// - Throws: CoreData 관련 에러
    func readTagsFromStore() throws -> [Tag] {
        guard let userId = UserDefaultsManager.shared.currentUserId else { return [] }
        
        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        let tagEntities = try coreDataStack.context.fetch(request)
        return tagEntities.map { entity in
            Tag(
                id: entity.id ?? "",
                name: entity.name ?? "",
                color: entity.color ?? "",
                userId: entity.userId ?? ""
            )
        }
    }
}


// MARK: - CoreData CRUD(단일)

extension CoreDataSyncService {
    // MARK: - Todo domain
    private func saveTodoToStore(_ todo: Todo) throws{
        try coreDataStack.performInTransaction {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", todo.id)
            let todoEntity = try coreDataStack.context.fetch(request).first ?? TodoEntity(context: coreDataStack.context)
            
            todoEntity.id = todo.id
            todoEntity.raw = todo.raw
            todoEntity.title = todo.title
            todoEntity.isImportant = todo.isImportant
            todoEntity.isLife = todo.isLife
            todoEntity.difficulty = Int16(todo.difficulty)
            todoEntity.estimatedTime = Int16(todo.estimatedTime)
            todoEntity.deadline = todo.deadline
            todoEntity.isCompleted = todo.isCompleted
            todoEntity.userId = todo.userId
            todoEntity.createdAt = todo.createdAt
            
            
            if let tag = todo.tag {
                try setupTagRelationship(for: todoEntity, with: tag)
            } else {
                todoEntity.tag = nil
            }
        }
    }
    
    func deleteTodoToStore(_ id: String) throws {
        try coreDataStack.performInTransaction {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            guard let todoEntity = try coreDataStack.context.fetch(request).first else {
                throw NSError(domain: "TodoNotFound", code: 404)
            }
            coreDataStack.context.delete(todoEntity)
        }
    }
    
    
    // MARK: - DailyStat
    private func saveDailyStatToStore(_ stat: DailyStat) throws {
        try coreDataStack.performInTransaction {
            let request = DailyStatEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "date == %@ AND userId == %@",
                stat.date,
                stat.userId
            )
            
            // 기존 데이터가 있으면 삭제
            if let existingEntity = try coreDataStack.context.fetch(request).first {
                coreDataStack.context.delete(existingEntity)
            }
            
            // 새 엔티티 생성
            let statEntity = DailyStatEntity(context: coreDataStack.context)
            statEntity.id = stat.id
            statEntity.date = stat.date
            statEntity.userId = stat.userId
            statEntity.productivityNum = stat.productivityNum
            statEntity.balanceTitle = stat.balanceData.title
            statEntity.balanceMessage = stat.balanceData.message
            statEntity.balanceNum = Int16(stat.balanceData.balanceNum)
            statEntity.centerX = stat.center.x
            statEntity.centerY = stat.center.y
            
            // TagStats 관계 설정
            try setupTagRelationship(for: statEntity, with: stat.tagStats)
        }
    }
    
    
    // MARK: - Tag
    
    private func saveTagToStore(_ tag: Tag) throws {
        try coreDataStack.performInTransaction {
            let request = TagEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", tag.id)
            
            let tagEntity = try coreDataStack.context.fetch(request).first ?? TagEntity(context: coreDataStack.context)
            
            tagEntity.id = tag.id
            tagEntity.color = tag.color
            tagEntity.name = tag.name
            tagEntity.userId = tag.userId
            tagEntity.lastUpdated = Date().koreanDate
            
        }
    }
    
    func deleteTagToStore(_ id: String) throws {
        try coreDataStack.performInTransaction {
            let request = TagEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            guard let tagEntity = try coreDataStack.context.fetch(request).first else {
                throw NSError(domain: "TagNotFound", code: 404)
            }
            
            coreDataStack.context.delete(tagEntity)
        }
    }
}


// MARK: - CoreData CRUD(복수) Batch Operations with Transaction

extension CoreDataSyncService {
    private func saveTodosToStore(_ todos: [Todo]) throws {
        try coreDataStack.performInTransaction {
            for todo in todos {
                try saveTodoToStore(todo)
            }
        }
    }
    
    private func saveDailyStatsToStore(_ stats: [DailyStat]) throws {
        try coreDataStack.performInTransaction {
            if let firstStat = stats.first {
                let yearMonth = String(firstStat.date.prefix(7))
                let request = DailyStatEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "date BEGINSWITH %@ AND userId == %@",
                    yearMonth,
                    firstStat.userId
                )
                
                let existingEntities = try coreDataStack.context.fetch(request)
                existingEntities.forEach { coreDataStack.context.delete($0) }
            }
            
            for stat in stats {
                try saveDailyStatToStore(stat)
            }
        }
    }
    
    private func saveTagsToStore(_ tags: [Tag]) throws {
        try coreDataStack.performInTransaction {
            for tag in tags {
                let request = TagEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", tag.id)
                
                let tagEntity = try coreDataStack.context.fetch(request).first ?? TagEntity(context: coreDataStack.context)
                tagEntity.id = tag.id
                tagEntity.name = tag.name
                tagEntity.color = tag.color
                tagEntity.userId = tag.userId
            }
        }
    }
    
    
    // TODO: Debug needed
    private func setupTagRelationship(for statEntity: DailyStatEntity, with tagStats: [TagStat]) throws {
        // 기존 관계 제거
        if let existingStats = statEntity.tagStats as? Set<TagStatEntity> {
            for stat in existingStats {
                statEntity.removeFromTagStats(stat)
                coreDataStack.context.delete(stat)
            }
        }
        
        // 새로운 TagStat 관계 설정
        for tagStat in tagStats {
            let tagStatEntity = TagStatEntity(context: coreDataStack.context)
            tagStatEntity.id = tagStat.id
            tagStatEntity.count = Int16(tagStat.count)
            
            // Tag 관계 설정 -> 여기서 local 저장소에 tagStat에 명시된 id값을 지닌 tag가 없을 경우, tag가 연결되지 않음에 따라 버그 발생
            let tagRequest = TagEntity.fetchRequest()
            tagRequest.predicate = NSPredicate(format: "id == %@", tagStat.tag.id)
            
            if let tagEntity = try coreDataStack.context.fetch(tagRequest).first {
                tagStatEntity.tag = tagEntity
                statEntity.addToTagStats(tagStatEntity)
                tagStatEntity.dailyStat = statEntity
            }
        }
    }
    
    /// Tag 관계 설정을 위한 헬퍼 메서드
    private func setupTagRelationship(for todoEntity: TodoEntity, with tag: Tag) throws {
        /// 전달받은 Tag에 대한 Entity가 로컬에 존재하는지 파악하고, 있으면 그대로 전달받은 부모 Entity에 주입, 없으면 새로 만들어서 주입
        let tagRequest = TagEntity.fetchRequest()
        tagRequest.predicate = NSPredicate(format: "id == %@", tag.id)
        
        let tagEntity = try coreDataStack.context.fetch(tagRequest).first ?? nil
        
        todoEntity.tag = tagEntity
    }
}

/// SyncQueue는 오프라인 상태에서의 작업을 관리하는 큐입니다.
/// - 작업의 저장, 실행, 재시도를 관리합니다.
/// - 네트워크 연결 시 자동으로 저장된 작업을 처리합니다.
private class SyncQueue {
    private let coreDataStack: CoreDataStack = .shared
    
    private let todoService: TodoServiceProtocol
    private let tagService: TagServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    
    private var syncTimer: Timer?
    private var retryInterval: TimeInterval = 15
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todoService: TodoServiceProtocol = TodoService(),
        tagService: TagServiceProtocol = TagService(),
        dailyStatService: DailyStatServiceProtocol = DailyStatService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
        self.dailyStatService = dailyStatService
    }
    // TODO: process 함수 CoreSyncService로 이동시킨 후, !isConnected상태일때, SyncQueue로 이동
    func process(_ command: SyncCommand) -> AnyPublisher<Any, Error> {
        
        if NetworkManager.shared.isConnected {
            print("2.process online: \(command.operation.type)".prefix(56))
            return executeCommand(command) // 온라인: 즉시 서버와 동기화
        } else {
            print("2.process offline: \(command.operation.type)".prefix(56))
            return Future { promise in
                do {
                    try self.saveCommand(command)
                    switch command.operation.type {
                    case .updateTodo(let todo):
                        promise(.success(todo))
                    case .updateTag(let tag):
                        promise(.success(tag))
                    case .deleteTodo(let todoId):
                        promise(.success(todoId))
                    case .deleteTag(let tagId):
                        promise(.success(tagId))
                    }
                } catch {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()
        }
    }
    
    
    private func executeCommand(_ command: SyncCommand) -> AnyPublisher<Any, Error> {
        switch command.operation.type {
        case .updateTodo(let todo):
            return todoService.updateTodo(todo: todo)
                .map { $0 as Any }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
        case .deleteTodo(let id):
            return todoService.deleteTodo(id: id)
                .map { $0.id as Any }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
        case .updateTag(let tag):
            return tagService.updateTag(tag)
                .map { $0 as Any }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            
        case .deleteTag(let id):
            return tagService.deleteTag(id: id)
                .map { $0 as Any }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
    }
    
    
    // MARK: - SyncQueue Background Processing
    
    func startSync() {
        stopSync()
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: retryInterval, repeats: true) { [weak self] _ in
            self?.processPendingCommands()
        }
        processPendingCommands()
        
    }
    
    func stopSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    private func processPendingCommands() {
        guard let commands = try? getPendingCommands(), !commands.isEmpty else {
            stopSync()
            return
        }
        
        for command in commands {
            print("startSync->processPendingCommand: \(command.operation.type)".prefix(64))
            executeCommand(command)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        
                        switch completion {
                        case .failure(let error):
                            print("processPendingCommands failed: \(error)")
                            let newRetryCount = command.retryCount + 1
                            if newRetryCount >= 3 {
                                try? self.markAsFailed(command.id, error: error)
                            } else {
                                try? self.updateRetryCount(command.id, count: newRetryCount)
                            }
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { [weak self] _ in
                        guard let self = self else { return }
                        try? self.markAsCompleted(command.id)
                        
                        // 모든 명령 처리 완료 후 상태 체크
                        if let remainingCommands = try? self.getPendingCommands(), remainingCommands.isEmpty {
                            self.stopSync()
                        }
                    }
                )
                .store(in: &cancellables)
        }
    }
    
}


// MARK: - Core Data Operations

private extension SyncQueue {
    func saveCommand(_ command: SyncCommand) throws {
        print("3.(off)saveCommand: \(command.operation.type)".prefix(56))
        try coreDataStack.performInTransaction {
            let entity = SyncCommandEntity(context: coreDataStack.context)
            entity.id = command.id
            entity.payload = try JSONEncoder().encode(command)
            entity.status = command.status.rawValue
            entity.createdAt = Date()
        }
    }
    
    func getPendingCommands() throws -> [SyncCommand] {
        let request = SyncCommandEntity.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", SyncStatus.pending.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let entities = try coreDataStack.context.fetch(request)
        return try entities.map {
            if let data = $0.payload {
                return try JSONDecoder().decode(SyncCommand.self, from: data)
            }
            throw NSError(domain: "SyncCommand", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid payload data"])
        }
    }
    
    func markAsCompleted(_ commandId: UUID) throws {
        try coreDataStack.performInTransaction {
            let request = SyncCommandEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", commandId as CVarArg)
            
            if let entity = try coreDataStack.context.fetch(request).first {
                entity.status = SyncStatus.completed.rawValue
            }
        }
    }
    
    private func updateRetryCount(_ commandId: UUID, count: Int) throws {
        print("\(commandId): updateRetryCount")
        try coreDataStack.performInTransaction {
            let request = SyncCommandEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", commandId as CVarArg)
            
            if let entity = try coreDataStack.context.fetch(request).first {
                var command = try JSONDecoder().decode(SyncCommand.self, from: entity.payload ?? Data())
                command.retryCount = count
                entity.payload = try JSONEncoder().encode(command)
            }
        }
    }

    private func markAsFailed(_ commandId: UUID, error: Error) throws {
        print("\(commandId): markAsFailed")
        try coreDataStack.performInTransaction {
            let request = SyncCommandEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", commandId as CVarArg)
            
            if let entity = try coreDataStack.context.fetch(request).first {
                var command = try JSONDecoder().decode(SyncCommand.self, from: entity.payload ?? Data())
                command.status = .failed
                command.errorMessage = error.localizedDescription
                entity.payload = try JSONEncoder().encode(command)
            }
        }
    }
}

