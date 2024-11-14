//
//  AppIntent.swift
//  widget
//
//  Created by Neoself on 10/16/24.
//

import WidgetKit
import AppIntents
import Alamofire
import Combine

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
    
    init() {}
    init(id: String) {
        self.id = id
    }
        
    func perform() async throws -> some IntentResult {
        let baseURL = APIConstants.baseUrl
        let endpoint = "/todo/toggle/\(id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(KeychainManager.shared.getAccessToken() ?? "")",
            "Content-Type": "application/json"
        ]
        
        guard let index = TodoDataModel.shared.todos.firstIndex(where: {$0.id == id}) else { return .result()}
        let originIsCompleted = TodoDataModel.shared.todos[index].isCompleted
        TodoDataModel.shared.todos[index].isCompleted.toggle()
        
        AF.request(baseURL + endpoint,
                   method: .patch,
                   encoding: URLEncoding.queryString,
                   headers: headers)
        .responseDecodable(of: Todo.self) { response in
            switch response.result {
            case .success:
                print("updated Successfully in Server")
            case .failure(let error):
                //MARK: 다시 원래 상태로 원상복구
                print("Error in toggleTodo Widget: \(error)")
                TodoDataModel.shared.todos[index].isCompleted = originIsCompleted
            }
        }
        .validate()
        return .result()
    }
}
