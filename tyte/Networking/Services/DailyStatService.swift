//
//  DailyStatService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Combine

class DailyStatService {
    private let apiManager = APIManager.shared
    
    func fetchAllDailyStats() -> AnyPublisher<[DailyStat], APIError> {
        let endpoint = APIEndpoint.fetchDailyStats
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[DailyStat], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
//    func fetchDailyStatForDate(_ date: String) -> AnyPublisher<DailyStat, APIError> {
//        let endpoint = APIEndpoint.fetchDailyStatForDate(date)
//        return apiManager.request(endpoint)
//    }
}
