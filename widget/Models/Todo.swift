//
//  TaskModel.swift
//  tyte
//
//  Created by Neoself on 10/16/24.
//
import Foundation

struct SimplifiedTodo: Codable, Identifiable {
    let id: String
    let title: String
    var isCompleted: Bool
}

//Sample Data Model
class TodoDataModel {
    static let shared = TodoDataModel()
    var todos: [SimplifiedTodo] = []
}
