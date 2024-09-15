//
//  MyPageViewModel.swift
//  tyte
//
//  Created by 김 형석 on 9/15/24.
//

import Foundation
import Combine
import SwiftUI

struct DailyStatForGraph: Identifiable {
    let id: String  // date를 id로 사용
    let date: String
    let productivityNum: Double
    var animate: Bool = false
    
    init(date: String, productivityNum: Double, animate: Bool = false) {
        self.id = date  // date를 id로 설정
        self.date = date
        self.productivityNum = productivityNum
        self.animate = animate
    }
}

class MyPageViewModel: ObservableObject {
    @Published var graphData: [DailyStatForGraph] = []
    @Published var isLoaded = false
    @Published var isLoading: Bool = false
    @Published var currentMode: String = "week" {
        didSet {
            fetchGraphData()
        }
    }
    
    @Published var errorMessage: String?
    
    private let dailyStatService: DailyStatService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dailyStatService: DailyStatService = DailyStatService()) {
        self.dailyStatService = dailyStatService
        print("MyPageViewModel init")
        self.fetchGraphData()
    }
    
    func fetchGraphData() {
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let currentDate = Date()
        var startDate: Date
        
        switch self.currentMode {
        case "week":
            startDate = calendar.date(byAdding: .day, value: -6, to: currentDate)!
        case "month":
            startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        default:
            // 기본값으로 6개월 전 날짜 사용
            startDate = calendar.date(byAdding: .month, value: -6, to: currentDate)!
        }
        
        dailyStatService.fetchDailyStatsForMonth(range:"\(startDate.apiFormat),\(currentDate.apiFormat)")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] dailyStats in
                guard let self = self else { return }
                if dailyStats.isEmpty {
                    graphData = []
                    isLoaded = true
                } else {
                    let dateRange = calendar.dateComponents([.day], from: startDate, to: currentDate).day! + 1
                    
                    let filteredDailyStats = (0..<dateRange).compactMap { dayOffset -> DailyStatForGraph? in
                        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { return nil }
                        
                        if let existingStat = dailyStats.first(where: { $0.date == date.apiFormat }) {
                            return DailyStatForGraph(
                                date: existingStat.date,
                                productivityNum: existingStat.productivityNum
                            )
                        } else {
                            return DailyStatForGraph(
                                date: date.apiFormat,
                                productivityNum: 0
                            )
                        }
                    }
                    graphData = filteredDailyStats
                    isLoaded = true
                    animateGraph()
                }
            }
            .store(in: &cancellables)
    }
    
    func zoomInOut() -> CGFloat {
        let baseWidth = UIScreen.main.bounds.width - 40
        let dataPointCount = graphData.count
        var spacingMultiplier: CGFloat = 1
        switch(currentMode){
        case "week":
            spacingMultiplier = 2
        case "month":
            spacingMultiplier = 1
        default:
            spacingMultiplier = 0.08
        }
        
        return max(baseWidth, CGFloat(dataPointCount) * 20 * spacingMultiplier)
    }
    
    func animateGraph(fromChange: Bool = false){
        for (index,_) in graphData.enumerated(){
            // For Some Reason Delay is Not Working
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ?
                    .easeInOut(duration: 0.2) :
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)
                ){
                    self.graphData[index].animate = true
                }
            }
        }
    }
}
