//
//  DailyStatService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Combine

class DailyStatService {
    static let shared = DailyStatService()
    private let apiManager = APIManager.shared
    
    func fetchAllDailyStats() -> AnyPublisher<[DailyStat], APIError> {
        let endpoint = APIEndpoint.fetchDailyStats
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[DailyStat], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchDailyStatsForMonth(range:String) -> AnyPublisher<[DailyStat], APIError> {
        let endpoint = APIEndpoint.fetchDailyStatsForMonth(range)
        
        return Future { promise in
            self.apiManager.request(endpoint) { (result: Result<[DailyStat], APIError>) in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}
