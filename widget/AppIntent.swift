//
//  AppIntent.swift
//  widget
//
//  Created by Neoself on 10/16/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
}

struct ToogleStateIntent:AppIntent {
    static var title: LocalizedStringResource = "Toggle Task State"
    
    // Parameters
    @Parameter(title:"Task ID")
    var id: String
    
    init() {
        
    }
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        //Update YOUR DATABASE HERE
        if let index = TodoDataModel.shared.todos.firstIndex(where: {
            $0.id == id
        }) {
            TodoDataModel.shared.todos[index].isCompleted.toggle()
            print("updated")
        }
        return .result()
    }
}
