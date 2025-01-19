import Foundation

protocol TodoLocalDataSourceProtocol {
    func getTodos(for date: String) throws -> [Todo]
    func getAllTodos() throws -> [Todo]
    func saveTodo(_ todo: Todo) throws
    func saveTodos(_ todos: [Todo]) throws
    func deleteTodo(_ id: String) throws
}

/// ``CoreData``를 사용하여 Todo 항목의 로컬 저장소 접근을 관리하는 DataSource입니다.
///
/// 다음과 같은 로컬 데이터 관리 기능을 제공합니다:
/// - Todo CRUD 작업
/// - 날짜별 Todo 필터링
/// - Tag 관계 관리
///
/// ## 사용 예시
/// ```swift
/// let localDataSource = TodoLocalDataSource()
///
/// // 특정 날짜의 Todo 조회
/// let todos = try localDataSource.getTodos(
///     for: "2024-01-20"
/// )
///
/// // Todo 저장 (태그 관계 포함)
/// try localDataSource.saveTodo(newTodo)
/// ```
///
/// ## 관련 타입
/// - ``CoreDataStack``
/// - ``TodoEntity``
/// - ``TagEntity``
/// - ``Todo``
///
/// - Important: Todo 저장 시 연관된 Tag가 로컬에 존재하지 않으면 Tag 관계가 설정되지 않습니다.
/// - Note: 날짜별 조회 시 중요도, 생성일자, 제목 순으로 정렬됩니다.
/// - Note: NSPredicate 사용을 위해 Foundation import가 필요합니다.
/// - SeeAlso: ``TodoRemoteDataSource``
class TodoLocalDataSource: TodoLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func getAllTodos() throws -> [Todo] {
        let request = TodoEntity.fetchRequest()
        
        let entities = try coreDataStack.context.fetch(request)
        return entities.map { entity in
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
                userId: entity.userId ?? "",
                createdAt: entity.createdAt ?? ""
            )
        }
    }
    
    func getTodos(for date: String) throws -> [Todo] {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deadline == %@", date)
        request.sortDescriptors = [
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let entities = try coreDataStack.context.fetch(request)
        return entities.map { entity in
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
                userId: entity.userId ?? "",
                createdAt: entity.createdAt ?? ""
            )
        }
    }
    
    func saveTodo(_ todo: Todo) throws {
        try coreDataStack.performInTransaction {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", todo.id)
            let entity = try coreDataStack.context.fetch(request).first ?? TodoEntity(context: coreDataStack.context)
            
            entity.id = todo.id
            entity.raw = todo.raw
            entity.title = todo.title
            entity.isImportant = todo.isImportant
            entity.isLife = todo.isLife
            entity.difficulty = Int16(todo.difficulty)
            entity.estimatedTime = Int16(todo.estimatedTime)
            entity.deadline = todo.deadline
            entity.isCompleted = todo.isCompleted
            entity.userId = todo.userId
            entity.createdAt = todo.createdAt
            
            if let tag = todo.tag {
                try setupTagRelationship(for: entity, with: tag)
            } else {
                entity.tag = nil
            }
        }
    }
    
    func saveTodos(_ todos: [Todo]) throws {
        try coreDataStack.performInTransaction {
            for todo in todos {
                try saveTodo(todo)
            }
        }
    }
    
    func deleteTodo(_ id: String) throws {
        try coreDataStack.performInTransaction {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            if let entity = try coreDataStack.context.fetch(request).first {
                coreDataStack.context.delete(entity)
            }
        }
    }
    
    /// DailyStat과 TagStat 간의 관계를 설정합니다.
    ///
    /// - Parameters:
    ///   - statEntity: 관계를 설정할 DailyStatEntity
    ///   - tagStats: 연결할 TagStat 배열
    ///
    /// 동작 과정:
    /// 1. 기존 TagStat 관계 모두 제거
    /// 2. 새로운 TagStatEntity 생성 및 관계 설정
    /// 3. 로컬 저장소의 Tag 존재 여부 확인 후 연결
    ///
    /// ```swift
    /// // 예시
    /// let dailyStatEntity = DailyStatEntity(context: context)
    /// try setupTagRelationship(
    ///     for: dailyStatEntity,
    ///     with: [tagStat1, tagStat2]
    /// )
    /// ```
    ///
    /// - Important: Tag가 로컬에 존재하지 않으면 해당 TagStat은 연결되지 않습니다.
    /// 이는 나중에 UI에서 Tag 정보를 표시할 때 문제가 될 수 있으므로, Tag 동기화가 먼저 이루어져야 합니다.
    ///
    /// - Warning: 이 메서드는 트랜잭션 내에서 호출되어야 합니다.
    /// - SeeAlso: ``TagLocalDataSource/saveTag(_:)``
    private func setupTagRelationship(for todoEntity: TodoEntity, with tag: Tag) throws {
        let tagRequest = TagEntity.fetchRequest()
        tagRequest.predicate = NSPredicate(format: "id == %@", tag.id)
        
        let tagEntity = try coreDataStack.context.fetch(tagRequest).first ?? nil
        
        todoEntity.tag = tagEntity
    }
}
