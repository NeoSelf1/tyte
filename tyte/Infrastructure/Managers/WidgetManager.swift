import Foundation
import WidgetKit

enum WidgetType{
    case all
    case calendar
    case todoList
}

/// 위젯 업데이트를 관리하는 싱글톤 클래스입니다.
///
/// 다음과 같은 위젯 관리 기능을 제공합니다:
/// - 캘린더/Todo 위젯 타임라인 갱신
/// - 선택적 위젯 업데이트
///
/// ## 사용 예시
/// ```swift
/// // 모든 위젯 업데이트
/// WidgetManager.shared.updateWidget(.all)
///
/// // 특정 위젯만 업데이트
/// WidgetManager.shared.updateWidget(.calendar)
/// ```
///
/// ## 관련 타입
/// - ``CalendarWidget``
/// - ``TodoListWidget``
///
/// - Note: WidgetCenter를 통해 위젯 타임라인을 리로드합니다.
/// - SeeAlso: ``UserDefaultsManager``, 위젯과 데이터 공유에 사용
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
