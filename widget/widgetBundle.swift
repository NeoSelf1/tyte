//
//  widgetBundle.swift
//  widget
//
//  Created by Neoself on 10/16/24.
//

import WidgetKit
import SwiftUI


// 앱에 포함된 모든 위젯 그룹화.
@main
struct widgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        CalendarWidget()
        TodoListWidget()
    }
}
