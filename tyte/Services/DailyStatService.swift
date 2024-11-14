//
//  DailyStatService.swift
//  tyte
//
//  Created by 김 형석 on 9/9/24.
//

import Foundation
import Combine

class DailyStatService: DailyStatServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDailyStat(for date: String) -> AnyPublisher<DailyStat, APIError> {
        return networkService.request(.fetchDailyStatsForDate(date), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(range: String) -> AnyPublisher<[DailyStat], APIError> {
        return networkService.request(.fetchDailyStatsForMonth(range), method: .get, parameters: nil)
    }
    
    func fetchMonthlyStats(for id: String, in range: String) -> AnyPublisher<[DailyStat], APIError> {
        return networkService.request(.getFriendDailyStats(friendId: id, range: range), method: .get, parameters: nil)
    }
}
