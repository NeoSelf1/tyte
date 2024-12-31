//
//  WidgetService.swift
//  tyte
//
//  Created by Neoself on 12/27/24.
//
import Foundation
import WidgetKit
enum WidgetType{
    case all
    case calendar
    case todoList
}

class WidgetService: WidgetServiceProtocol {
    func updateWidget(_ type: WidgetType) {
        switch type {
        case .all:
            WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
        case .calendar:
            WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
        case .todoList:
            WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
        }
    }
}
