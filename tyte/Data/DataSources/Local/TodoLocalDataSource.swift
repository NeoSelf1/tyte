//
//  TodoLocalDataSourceImpl.swift
//  tyte
//
//  Created by Neoself on 1/14/25.
//
import Foundation

protocol TodoLocalDataSourceProtocol {
    func getTodos(for date: String) throws -> [Todo]
    func saveTodos(_ todos: [Todo]) throws
    func updateTodo(_ todo: Todo) throws
    func deleteTodo(_ id: String) throws
}

class TodoLocalDataSource: TodoLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getTodos(for date: String) throws -> [Todo] {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deadline == %@", date)
        request.sortDescriptors = [
            NSSortDescriptor(key: "isImportant", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
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
    
    func saveTodos(_ todos: [Todo]) throws {
        try coreDataStack.performInTransaction {
            for todo in todos {
                try saveTodo(todo)
            }
        }
    }
    
    func updateTodo(_ todo: Todo) throws {
        try coreDataStack.performInTransaction {
            try saveTodo(todo)
        }
    }
    
    private func saveTodo(_ todo: Todo) throws {
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
}
