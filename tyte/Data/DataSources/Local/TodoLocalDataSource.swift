import Foundation

protocol TodoLocalDataSourceProtocol {
    func getTodos(for date: String) throws -> [Todo]
    func getAllTodos() throws -> [Todo]
    func saveTodo(_ todo: Todo) throws
    func saveTodos(_ todos: [Todo]) throws
    func deleteTodo(_ id: String) throws
}

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
    
    /// Tag 관계 설정을 위한 헬퍼 메서드
    private func setupTagRelationship(for todoEntity: TodoEntity, with tag: Tag) throws {
        /// 전달받은 Tag에 대한 Entity가 로컬에 존재하는지 파악하고, 있으면 그대로 전달받은 부모 Entity에 주입, 없으면 nil
        let tagRequest = TagEntity.fetchRequest()
        tagRequest.predicate = NSPredicate(format: "id == %@", tag.id)
        
        let tagEntity = try coreDataStack.context.fetch(tagRequest).first ?? nil
        
        todoEntity.tag = tagEntity
    }
}
