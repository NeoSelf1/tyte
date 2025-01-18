/// 앱의 모든 위젯을 관리하는 번들
///
/// CalendarWidget과 TodoListWidget을 하나의 번들로 그룹화하여 관리합니다.
/// @main 속성을 통해 위젯의 진입점 역할을 합니다.
import WidgetKit
import SwiftUI

@main
struct widgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        CalendarWidget()
        TodoListWidget()
    }
}
