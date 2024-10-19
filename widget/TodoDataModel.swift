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
    var todos: [Todo] = [
        Todo(
            id: "1",
            raw: "중요한 프레젠테이션 준비하기",
            title: "중요한 프레젠테이션 준비하기",
            isImportant: true,
            isLife: false,
            tagId: Tag(id: "work", name: "업무", color: "FF0000", user: "user1"),
            difficulty: 4,
            estimatedTime: 120,
            deadline: "2024-10-20",
            isCompleted: false,
            user: "user1"
        ),
        Todo(
            id: "2",
            raw: "운동가기 30분",
            title: "운동가기",
            isImportant: false,
            isLife: true,
            tagId: Tag(id: "health", name: "건강", color: "00FF00", user: "user1"),
            difficulty: 2,
            estimatedTime: 30,
            deadline: "2024-10-19",
            isCompleted: false,
            user: "user1"
        ),
        Todo(
            id: "3",
            raw: "친구와 저녁 약속",
            title: "친구와 저녁 약속",
            isImportant: false,
            isLife: true,
            tagId: Tag(id: "social", name: "사회생활", color: "0000FF", user: "user1"),
            difficulty: 1,
            estimatedTime: 120,
            deadline: "2024-10-21",
            isCompleted: false,
            user: "user1"
        )
    ]
}
