/// 앱의 위젯 업데이트를 관리하는 싱글톤 클래스
///
/// 앱의 상태 변화에 따라 위젯의 타임라인을 업데이트하는 기능을 제공합니다.
/// 캘린더 위젯과 할 일 목록 위젯을 개별적으로 또는 동시에 업데이트할 수 있습니다.
///
/// - Note: WidgetCenter를 통해 위젯의 타임라인을 리로드합니다.
import Foundation
import WidgetKit

enum WidgetType{
    case all
    case calendar
    case todoList
}

final class WidgetManager {
    static let shared = WidgetManager()
    
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
