//
//  TaskModel.swift
//  tyte
//
//  Created by Neoself on 10/16/24.
//
import Foundation

//Sample Data Model
class TodoDataModel {
    static let shared = TodoDataModel()
    var todos: [Todo] = []
}
