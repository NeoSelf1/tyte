//
//  MyPageViewModel.swift
//  tyte
//
//  Created by 김 형석 on 9/15/24.
//

import Foundation
import Combine
import SwiftUI

class MyPageViewModel: ObservableObject {
    @Published var isLoaded = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentMonth: Date = Date().koreanDate
    @Published var selectedDate: Date = Date().koreanDate
    
    @Published var currentTab: Int = 0
    @Published var graphRange: String = "week" {
        didSet {
            fetchDailyStats()
        }
    }
    private let dailyStatService: DailyStatService
    private let authService: AuthService
    
    @Published var calenderData: [DailyStat_DayView] = []
    @Published var graphData: [DailyStat_Graph] = []

    init(
        dailyStatService: DailyStatService = DailyStatService(),
         authService: AuthService = AuthService()
    ) {
        self.dailyStatService = dailyStatService 
        self.authService = authService
        print("MyPageViewModel init")
        self.fetchDailyStats()
    }
    
    func fetchDailyStats() {
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let currentDate = Date().koreanDate
        var startDate: Date
        
        switch self.graphRange {
        case "week":
            startDate = calendar.date(byAdding: .day, value: -6, to: currentDate)!
        default:
            startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        }
        
        dailyStatService.fetchDailyStatsForMonth(range:"\(startDate.apiFormat),\(currentDate.apiFormat)")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] _dailyStats in
                guard let self = self else { return }
                if _dailyStats.isEmpty {
                    isLoaded = true
                } else {
                    calenderData = _dailyStats.map { dailyStat -> DailyStat_DayView in
                        return DailyStat_DayView(
                            date: dailyStat.date,
                            balanceData: dailyStat.balanceData,
                            tagStats: dailyStat.tagStats,
                            center: dailyStat.center
                        )
                    }
                    
                    let dateRange = calendar.dateComponents([.day], from: startDate, to: currentDate).day! + 1
                    graphData = (0..<dateRange).compactMap { dayOffset -> DailyStat_Graph? in
                        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { return nil }
                        
                        if let existingStat = _dailyStats.first(where: { $0.date == date.apiFormat }) {
                            return DailyStat_Graph(
                                date: existingStat.date,
                                productivityNum: existingStat.productivityNum
                            )
                        } else {
                            return DailyStat_Graph(
                                date: date.apiFormat,
                                productivityNum: 0
                            )
                        }
                    }
                    isLoaded = true
                    animateGraph()
                }
            }
            .store(in: &cancellables)
    }
    
    func zoomInOut() -> CGFloat {
        let baseWidth = UIScreen.main.bounds.width - 40
        let dataPointCount = graphData.count
        let spacingMultiplier: CGFloat = graphRange == "week" ? 2: 1
        
        return max(baseWidth, CGFloat(dataPointCount) * 20 * spacingMultiplier)
    }
    
    func animateGraph(){
        for (index,_) in graphData.enumerated(){
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(graphRange == "week" ? 0.5 : 0) + Double(index) * (graphRange == "week" ? 0.05 : 0.03)){
                withAnimation( // 현재 BlendDuration은 어떠한 시각적 효과가 없음.
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.3)
                ){
                    self.graphData[index].animate = true
                }
            }
        }
    }
}
