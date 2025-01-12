/// Todo 목록을 표시하는 위젯
///
/// 오늘의 할 일 목록을 위젯으로 표시하며, 시스템 사이즈에 따라 다른 레이아웃을 제공합니다.
///
/// - SupportedFamilies:
///   - small: 프리즘과 최대 3개의 Todo 항목 표시
///   - medium: 프리즘과 최대 3개의 Todo 항목을 가로 배치
///   - large: 프리즘과 최대 5개의 Todo 항목을 세로 배치
///
/// - Note: CoreData를 통해 데이터를 관리하며, 자정에 데이터가 갱신됩니다.
import WidgetKit
import SwiftUI

/// Todo 목록 위젯의 데이터 제공자
///
/// TimelineProvider 프로토콜을 구현하여 위젯의 데이터를 관리합니다.
struct TodoListWidgetProvider: TimelineProvider {
    /// 위젯의 플레이스홀더 상태를 제공합니다.
    /// - Parameter context: 위젯 컨텍스트
    /// - An object that contains details about how a widget is rendered, including its size and whether it appears in the widget gallery.
    /// - Returns: 더미 데이터가 포함된 엔트리
    func placeholder(in context: Context) -> TodoListEntry {
        return TodoListEntry(
            date: Date().koreanDate,
            dailyStat: .dummyStat,
            todos: [.mock,.mock1,.mock2]
        )
    }
    
    /// 위젯의 현재 상태의 스냅샷을 제공합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트
    ///   - completion: 스냅샷 완료 핸들러
    func getSnapshot(in context: Context, completion: @escaping (TodoListEntry) -> ()) {
        completion(TodoListEntry(
            date: Date().koreanDate,
            dailyStat: .dummyStat,
            todos: [.mock,.mock1,.mock2]
        ))
    }
    
    /// 위젯의 시간에 따른 업데이트 타임라인을 제공합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트
    ///   - completion: 타임라인 생성 완료 핸들러
    /// - Note: 자정을 기준으로 데이터가 갱신됩니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoListEntry>) -> ()) {
        let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        
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
                    tag: Tag(
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
            
            let timeline = Timeline(
                entries: [TodoListEntry(
                    date: Date().koreanDate,
                    dailyStat: dailyStat,
                    todos: todos
                )],
                policy: .after(nextMidnight)
            )
            
            completion(timeline)
        } else {
            dailyStat = .dummyStat
            todos = []
            
            let timeline = Timeline(
                entries: [TodoListEntry(
                    date: Date().koreanDate,
                    dailyStat: dailyStat,
                    todos: todos
                )],
                policy: .after(nextMidnight)
            )
            
            completion(timeline)
        }
    }
}

struct TodoListEntry: TimelineEntry {
    let date: Date
    let dailyStat: DailyStat
    let todos: [Todo]
}

struct TodoListWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: TodoListWidgetProvider.Entry
    
    var body: some View {
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
            TodoListWidgetEntryView(entry: entry)
                .padding()
                .background(.gray10)
            
        }
        .configurationDisplayName("TyTE 할일 리스트")
        .description("할일들을 한눈에 확인해보세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#if DEBUG
struct TodoListWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodoListWidgetEntryView(
            entry: TodoListEntry(
                date: Date().koreanDate,
                dailyStat: .empty,
                todos:[.mock,.mock2,.mock1]
//                todos:[]
            )
        )
        .containerBackground(.gray10, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
