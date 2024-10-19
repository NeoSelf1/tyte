//
//  widget.swift
//  widget
//
//  Created by Neoself on 10/16/24.
//
import WidgetKit
import SwiftUI
import Alamofire
import Combine

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
            let todos = try await fetchTodosForDate(deadline: Date().koreanDate.apiFormat)
            TodoDataModel.shared.todos = todos
            return Timeline(entries: [TodoEntry(filteredTodos: Array(todos.prefix(3)))], policy: .atEnd)
        } catch {
            print("Error fetching todos: \(error.localizedDescription)")
            return Timeline(entries: [TodoEntry(filteredTodos: [])], policy: .atEnd)
        }
    }

    func fetchTodosForDate(deadline: String) async throws -> [Todo] {
        let baseURL = APIManager.shared.baseURL
        let endpoint = APIEndpoint.fetchTodosForDate(deadline).path
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(String(describing: APIManager.shared.getToken()))",
            "Content-Type": "application/json"
        ]
        
        return try await AF.request(baseURL + endpoint,
                                    method: .get,
                                    encoding: URLEncoding.queryString,
                                    headers: headers)
        .validate()
        .serializingDecodable([Todo].self)
        .value
    }
}

// 위젯에 표시될 데이터 구조 정의
struct TodoEntry: TimelineEntry {
    let date: Date = .now
    var filteredTodos:[Todo]
}

// 실제 UI 뷰
struct TodoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (alignment:.leading,spacing: 2){
            Text(Date().koreanDate.formattedMonthDate)
                .font(._subhead1)
                .padding(.bottom,10)
            
            if entry.filteredTodos.isEmpty {
                Text("Todo가 없어요")
                    .font(._body2)
                    .foregroundStyle(.gray50)
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                
            } else {
                ForEach(entry.filteredTodos){ todo in
                    HStack(alignment: .top, spacing:4) {
                        Button(intent: ToogleStateIntent(id: todo.id)){
                            Image(systemName: todo.isCompleted ? "checkmark.square.fill": "square")
                                .foregroundStyle(.blue30)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(todo.title)
                                .font(._caption)
                                .lineLimit(1)
                            
                            Divider()
                        }
                    }
                    
                    if todo.id != entry.filteredTodos.last?.id {
                        Spacer().frame(maxHeight: 8)
                    }
                }
                Spacer()
            }
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
