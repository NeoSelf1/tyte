//
//  CoreDataSyncService.swift
//  tyte
//
//  Created by Neoself on 12/26/24.
//

/// 1. 네트워크에서 데이터 fetch 후 CoreData 저장
/// 2. CoreData에서 데이터 읽기
/// 3. 사용자 변경 시 데이터 삭제
/// 4. 데이터 동기화 및 충돌 관리

// MARK: save = create || update

import Combine
import CoreData
// TODO: Repository 패턴으로 분리하여 관심사 분리 및 의존성 방향 역전
// TODO: 동기화 상태 추적 : 각 엔티티의 마지막 동기화 시간 추적 필요

class CoreDataSyncService {
    static let shared = CoreDataSyncService()
    
    private let coreDataStack = CoreDataStack.shared
    
    private let todoService: TodoServiceProtocol
    private let tagService: TagServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    
    init(
        todoService: TodoServiceProtocol = TodoService(),
        tagService: TagServiceProtocol = TagService(),
        dailyStatService: DailyStatServiceProtocol = DailyStatService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
        self.dailyStatService = dailyStatService
    }
    
    
    // MARK: - 네트워크 통신으로 데이터 fetch 후, CoreData로 영구저장소와 동기화
    
    
    /// 특정 날짜의 Todo 목록을 fetch하고 CoreData와 동기화
    /// - Parameter date: 조회할 날짜
    /// - Returns: 동기화된 Todo 목록을 포함한 Publisher
    func fetchSyncTodosForDate(_ date: String) -> AnyPublisher<[Todo], Error> {
        return todoService.fetchTodos(for: date)
            .tryMap { [weak self] todos in
                try self?.saveTodosToStore(todos)
                return todos
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// Todo 삭제 및 CoreData 동기화
    func deleteSyncTodo(_ id: String) -> AnyPublisher<Todo, Error> {
        return todoService.deleteTodo(id: id)
            .tryMap { [weak self] deletedTodo in
                try self?.deleteTodoToStore(deletedTodo.id)
                return deletedTodo
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// DailyStat fetch 및 CoreData 동기화
    func fetchSyncDailyStat(for deadline: String) -> AnyPublisher<DailyStat?, Error> {
        return dailyStatService.fetchDailyStat(for: deadline)
            .tryMap { [weak self] dailyStat in
                try self?.saveDailyStatToStore(dailyStat ?? .empty)
                return dailyStat
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// DailyStats fetch 및 CoreData 동기화
    func fetchSyncDailyStats(for yearMonth: String) -> AnyPublisher<[DailyStat], Error> {
        return dailyStatService.fetchMonthlyStats(in: yearMonth)
            .tryMap { [weak self] stats in
                print(stats)
                try self?.saveDailyStatsToStore(stats)
                return stats
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// Tags fetch 및 CoreData 동기화
    func fetchSyncTags() -> AnyPublisher<[Tag], Error> {
        return tagService.fetchTags()
            .tryMap { [weak self] tags in
                try self?.saveTagsToStore(tags)
                return tags
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// Todo 생성 및 CoreData 동기화
    func createSyncTodoForDate(text: String,in deadline:String) -> AnyPublisher<[Todo], Error>{
        return todoService.createTodo(text: text, in: deadline)
            .tryMap { [weak self] newTodos in
                try self?.saveTodosToStore(newTodos)
                return newTodos
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    /// Todo 수정(Update) 및 CoreData 동기화
    func updateSyncTodoForDate(_ todo: Todo) -> AnyPublisher<Todo, Error>{
        return todoService.updateTodo(todo:todo)
            .tryMap { [weak self] updatedTodo in
                try self?.saveTodoToStore(updatedTodo)
                return updatedTodo
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}


// MARK: - 영구저장소에서 데이터 Read

extension CoreDataSyncService {
    func readTodosFromStore(for date: String) throws -> [Todo] {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deadline == %@", date)
        request.sortDescriptors = [
                NSSortDescriptor(key: "isImportant", ascending: false),
                NSSortDescriptor(key: "createdAt", ascending: true)
            ]
        
        let todoEntities = try coreDataStack.context.fetch(request)
        return todoEntities.map { entity in
            Todo(
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
                userId: entity.userId ?? ""
            )
        }
    }
    
    func readDailyStatsFromStore(for yearMonth: String) throws -> [DailyStat] {
        let request = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date BEGINSWITH %@", yearMonth)
        
        let statEntities = try coreDataStack.context.fetch(request)
        return statEntities.map { entity in
            DailyStat(
                id: entity.id ?? "",
                date: entity.date ?? "",
                userId: entity.userId ?? "",
                balanceData: BalanceData(
                    title: entity.balanceTitle ?? "",
                    message: entity.balanceMessage ?? "",
                    balanceNum: Int(entity.balanceNum)
                ),
                productivityNum: entity.productivityNum,
                tagStats: [], // TODO: Handle tagStats relationship
                center: SIMD2<Float>(entity.centerX, entity.centerY)
            )
        }
    }
    
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
    
    /// CoreData에 Todo 저장 시 동기화 상태 관리
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
            
            if todoEntity.createdAt == nil {
                todoEntity.createdAt = Date()
            }
            
            if let tag = todo.tag {
                try setupTagRelationship(for: todoEntity, with: tag)
            } else {
                todoEntity.tag = nil
            }
        }
    }
    
    private func saveDailyStatToStore(_ stat: DailyStat) throws {
        try coreDataStack.performInTransaction {
            let request = DailyStatEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", stat.id)
            
            let statEntity = try coreDataStack.context.fetch(request).first ?? DailyStatEntity(context: coreDataStack.context)
            statEntity.id = stat.id
            statEntity.date = stat.date
            statEntity.userId = stat.userId
            statEntity.productivityNum = stat.productivityNum
            statEntity.balanceTitle = stat.balanceData.title
            statEntity.balanceMessage = stat.balanceData.message
            statEntity.balanceNum = Int16(stat.balanceData.balanceNum)
            statEntity.centerX = stat.center.x
            statEntity.centerY = stat.center.y
            
            // TODO: Save tagStats relationship 버그 수정
//            try setupTagRelationship(for: statEntity, with: stat.tagStats)
        }
    }
    
    /// deleteTodo : Todo 삭제
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
}


// MARK: - CoreData CRUD(복수) Batch Operations with Transaction

extension CoreDataSyncService{
    private func saveTodosToStore(_ todos: [Todo]) throws {
        try coreDataStack.performInTransaction {
            for todo in todos {
                try saveTodoToStore(todo)
            }
        }
    }
    
    private func saveDailyStatsToStore(_ stats: [DailyStat]) throws {
        try coreDataStack.performInTransaction {
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
    
    // MARK: 사용자 변경 시 데이터 삭제
    private func clearUserData(for userId: String) throws {
        try coreDataStack.performInTransaction {
            let entities = ["TodoEntity", "TagEntity", "DailyStatEntity", "TagStatEntity"]
            
            for entityName in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try coreDataStack.context.execute(deleteRequest)
            }
        }
    }
    
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
            
            // Tag 관계 설정
            let tagRequest = TagEntity.fetchRequest()
            tagRequest.predicate = NSPredicate(format: "id == %@", tagStat.id)
            
            if let tagEntity = try coreDataStack.context.fetch(tagRequest).first {
                tagStatEntity.tag = tagEntity
            }
            
            statEntity.addToTagStats(tagStatEntity)
            tagStatEntity.dailyStat = statEntity
        }
    }
    
    /// Tag 관계 설정을 위한 헬퍼 메서드
    private func setupTagRelationship(for todoEntity: TodoEntity, with tag: Tag) throws {
        /// 전달받은 Tag에 대한 Entity가 로컬에 존재하는지 파악하고, 있으면 그대로 전달받은 부모 Entity에 주입, 없으면 새로 만들어서 주입
        let tagRequest = TagEntity.fetchRequest()
        tagRequest.predicate = NSPredicate(format: "id == %@", tag.id)
        
        let tagEntity = try coreDataStack.context.fetch(tagRequest).first ?? {
            let newTagEntity = TagEntity(context: coreDataStack.context)
            newTagEntity.id = tag.id
            newTagEntity.name = tag.name
            newTagEntity.color = tag.color
            newTagEntity.userId = tag.userId
            return newTagEntity
        }()
        
        todoEntity.tag = tagEntity
    }
}
