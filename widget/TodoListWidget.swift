//
//  TodoListWidgetProvider.swift
//  tyte
//
//  Created by Neoself on 12/29/24.
//


import WidgetKit
import SwiftUI

struct TodoListWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoListEntry {
        return TodoListEntry(
            date: Date().koreanDate,
            dailyStat: .dummyStat,
            todos: [.mock,.mock1,.mock2],
            isLoggedIn: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodoListEntry) -> ()) {
        let defaults = UserDefaultsManager.shared
        
        if defaults.isLoggedIn {
            completion(TodoListEntry(
                date: Date().koreanDate,
                dailyStat: .dummyStat,
                todos: [.mock,.mock1,.mock2],
                isLoggedIn: true
            ))
        } else {
            completion(TodoListEntry(
                date: Date().koreanDate,
                dailyStat: .dummyStat,
                todos: [],
                isLoggedIn: false
            ))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoListEntry>) -> ()) {
        let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        
        if UserDefaultsManager.shared.isLoggedIn {
            let dailyStat: DailyStat
            let todos:[Todo]
            
            let date = Date().koreanDate.apiFormat
            let dailyStatRequest = DailyStatEntity.fetchRequest()
            let todoRequest = TodoEntity.fetchRequest()
            dailyStatRequest.predicate = NSPredicate(format: "date == %@", date)
            todoRequest.predicate = NSPredicate(format: "deadline == %@", date)
            
            if let statEntity = try? CoreDataStack.shared.context.fetch(dailyStatRequest)[0],
               let todoEntities = try? CoreDataStack.shared.context.fetch(todoRequest) {
                let tagStats: [TagStat] = (statEntity.tagStats as? Set<TagStatEntity>)?.map { tagStatEntity in
                    TagStat(
                        id: tagStatEntity.id ?? "",
                        tag: _Tag(
                            id: tagStatEntity.tag?.id ?? "",
                            name: tagStatEntity.tag?.name ?? "",
                            color: tagStatEntity.tag?.color ?? "",
                            userId: tagStatEntity.tag?.userId ?? ""
                        ),
                        count: Int(tagStatEntity.count)
                    )
                } ?? []
                
                dailyStat = DailyStat(
                    id: statEntity.id ?? "",
                    date: statEntity.date ?? "",
                    userId: statEntity.userId ?? "",
                    balanceData: BalanceData(
                        title: statEntity.balanceTitle ?? "",
                        message: statEntity.balanceMessage ?? "",
                        balanceNum: Int(statEntity.balanceNum)
                    ),
                    productivityNum: statEntity.productivityNum,
                    tagStats: tagStats,
                    center: SIMD2<Float>(statEntity.centerX, statEntity.centerY)
                )
                
                todos = todoEntities.map { entity in
                    return Todo(
                        id: entity.id ?? "",
                        raw: entity.raw ?? "",
                        title: entity.title ?? "",
                        isImportant: entity.isImportant,
                        isLife: entity.isLife,
                        difficulty: Int(entity.difficulty),
                        estimatedTime: Int(entity.estimatedTime),
                        deadline: entity.deadline ?? "",
                        isCompleted: entity.isCompleted,
                        userId: entity.userId ?? "",
                        createdAt: entity.createdAt ?? ""
                    )
                }
            } else {
                dailyStat = .dummyStat
                todos = []
            }

            let timeline = Timeline(
                entries: [TodoListEntry(
                    date: Date().koreanDate,
                    dailyStat: dailyStat,
                    todos: todos,
                    isLoggedIn: true
                )],
                policy: .after(nextMidnight)
            )
            
            completion(timeline)
        } else {
            let emptyTimeline = Timeline(
                entries: [TodoListEntry(
                    date: Date().koreanDate,
                    dailyStat: .dummyStat,
                    todos: [],
                    isLoggedIn: false
                )],
                policy: .after(nextMidnight)
            )
            
            completion(emptyTimeline)
        }
    }
}

struct TodoListEntry: TimelineEntry {
    let date: Date
    let dailyStat: DailyStat
    let todos: [Todo]
    let isLoggedIn: Bool
}

struct TodoListWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: TodoListWidgetProvider.Entry
    
    var body: some View {
        if entry.isLoggedIn {
            if family == .systemLarge {
                VStack(alignment:.center, spacing:20) {
                    HStack{
                        Text(entry.date.formattedMonthDate)
                            .font(._body2)
                            .foregroundStyle(.gray90)
                        
                        Spacer()
                        
                        Text("\(entry.todos.filter{!$0.isCompleted}.count)/\(entry.todos.count)")
                            .font(._caption)
                            .foregroundStyle(.gray50)
                    }
                    
                    DayView(
                        dailyStat: entry.dailyStat,
                        date: entry.date,
                        isToday:false,
                        isDayVisible: false,
                        size:92,
                        isCircleVisible: false
                    )
                    
                    todoList(maxNum: 5)
                }
            } else if family == .systemMedium {
                VStack(alignment:.leading, spacing:12) {
                    HStack {
                        Text(entry.date.formattedMonthDate)
                            .font(._body2)
                            .foregroundStyle(.gray90)
                        
                        Spacer()
                        
                        Text("\(entry.todos.filter{!$0.isCompleted}.count)/\(entry.todos.count)")
                            .font(._caption)
                            .foregroundStyle(.gray50)
                    }
                    
                    HStack(alignment: .top){
                        DayView(
                            dailyStat: entry.dailyStat,
                            date: entry.date,
                            isToday:false,
                            isDayVisible: false,
                            size:92,
                            isCircleVisible: false
                        )
                        .padding(.trailing,20)
                        
                        todoList(maxNum: 3)
                    }
                }
            } else {
                VStack(alignment:.leading, spacing:16) {
                    HStack(spacing:0) {
                        Text(entry.date.formattedMonthDate)
                            .font(._body2)
                            .foregroundStyle(.gray90)
                        
                        Spacer()
                        
                        DayView(
                            dailyStat: entry.dailyStat,
                            date: entry.date,
                            isToday:false,
                            isDayVisible: false,
                            size:48,
                            isCircleVisible: false
                        )
                        .frame(width:16, height:16)
                    }
                    
                    todoList(maxNum: 3)
                }
            }
        } else {
            VStack(spacing: 2) {
                Text("TyTE 앱에서")
                    .font(._caption)
                    .foregroundStyle(.gray50)
                
                Text("로그인이 필요해요")
                    .font(._subhead2)
                    .foregroundStyle(.gray50)
            }
        }
    }
    
    @ViewBuilder
    private func todoList(maxNum:Int)-> some View {
        if entry.todos.isEmpty {
            VStack(spacing: 8){
                Image("plus")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.gray50)
                    .frame(width: 24, height: 24)
                
                Text("투두 추가하기")
                    .font(._caption)
                    .foregroundStyle(.gray50)
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(.gray95.opacity(0.1))
            )
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.todos.sorted { !$0.isCompleted && $1.isCompleted }.prefix(maxNum)) { todo in
                    HStack(spacing:4) {
                        Circle().fill(Color(hex:todo.tag?.color ?? "747474")).frame(width: 4, height: 4)
                        
                        Text(todo.title)
                            .font(._caption)
                            .foregroundStyle(.gray70)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.gray95.opacity(0.1))
                    )
                    .opacity(todo.isCompleted ? 0.4 : 1)
                }
            }
            
            Spacer()
        }
    }
}

struct TodoListWidget: Widget {
    let kind: String = "TodoListWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TodoListWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                TodoListWidgetEntryView(entry: entry)
                    .containerBackground(.gray10, for: .widget)
            } else {
                TodoListWidgetEntryView(entry: entry)
                    .padding()
                    .background(.gray10)
            }
        }
        .configurationDisplayName("TyTE 할일 리스트")
        .description("할일들을 한눈에 확인해보세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TodoListWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodoListWidgetEntryView(
            entry: TodoListEntry(
                date: Date().koreanDate,
                dailyStat: .empty,
                todos:[.mock,.mock2,.mock1],
//                todos:[],
                isLoggedIn: true
            )
        )
        .containerBackground(.gray10, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
