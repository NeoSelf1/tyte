//
//  widget.swift
//  widget
//
//  Created by Neoself on 10/16/24.
//

import WidgetKit
import SwiftUI

// 위젯의 데이터를 제공하는 구조체
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(filteredTodos:Array(TodoDataModel.shared.todos.prefix(3)))
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TodoEntry {
        TodoEntry(filteredTodos:Array(TodoDataModel.shared.todos.prefix(3)))
    }
    
    // 위젯이 업데이트되는 시기와 표시할 데이터 결정
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TodoEntry> {
        do {
            let todos = try await fetchTodosForDate(deadline: getTodayString())
//            TodoDataModel.shared.todos = todos
            let entry = [TodoEntry(filteredTodos: Array(todos.prefix(3)))]
            return Timeline(entries: entry, policy: .atEnd)
        } catch {
            print(error)
        }
        return Timeline(entries: [TodoEntry(filteredTodos: [])],policy: .atEnd)
    }
}

private func fetchTodosForDate(deadline: String) async throws -> [SimplifiedTodo] {
    return try await withCheckedThrowingContinuation { continuation in
        fetchTodosForDate(deadline: deadline) { result in
            switch result {
            case .success(let todos):
                continuation.resume(returning: todos)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

// 위젯에 표시될 데이터 구조 정의
struct TodoEntry: TimelineEntry {
    let date: Date = .now
    var filteredTodos:[SimplifiedTodo]
}

// 실제 UI 뷰
struct TodoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (alignment:.leading,spacing: 0){
            Text("Tasks")
                .font(.title2)
                .padding(.bottom,10)
            
            VStack(alignment: .leading, spacing: 6) {
                if entry.filteredTodos.isEmpty {
                    Text("No Tasks left")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                } else {
                    ForEach(entry.filteredTodos){ task in
                        HStack(spacing:6) {
                            Button(intent: ToogleStateIntent(id: task.id)){
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill": "circle")
                                    .foregroundStyle(.blue)
                            }.buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .textScale(.secondary)
                                    .lineLimit(1)
                                    .strikethrough(task.isCompleted, pattern: .solid,color:.gray)
                                
                                Divider()
                            }
                        }
                        
                        if task.id != entry.filteredTodos.last?.id {
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
        .onChange(of: entry.filteredTodos) {_,updatedData in
            print(updatedData)
        }
    }
}


// 위젯의 구성을 정의하는 구조체. 이름, 지원하는 크기, 설명 등 지정
struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TodoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("투두 위젯")
        .configurationDisplayName("할일 체크가 가능한 위젯이에요.")
    }
}

#Preview(as: .systemSmall) {
    widget()
} timeline: {
    TodoEntry(filteredTodos:Array(TodoDataModel.shared.todos))
}
