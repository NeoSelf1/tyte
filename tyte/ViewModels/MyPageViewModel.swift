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
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dailyStatService: DailyStatService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dailyStatService: DailyStatService = DailyStatService()) {
        self.dailyStatService = dailyStatService
        print("MyPageViewModel init")
        self.fetchGraphData()
    }
    
    func fetchGraphData() {
        dailyStatService.fetchAllDailyStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dailyStats in
                let calendar = Calendar.current
                let dateRange = (0..<31).map { dayOffset in
                    calendar.date(byAdding: .day, value: -(31 - 1 - dayOffset), to: Date())!
                }
                print("fetchGraphData Done")
                let filteredDailyStats = dateRange.map { date in
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
                print(filteredDailyStats.debugDescription)
                self?.graphData = filteredDailyStats
                
            }
            .store(in: &cancellables)
    }
    
    func animateGraph(fromChange: Bool = false){
        for (index,_) in self.graphData.enumerated(){
            // For Some Reason Delay is Not Working
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ?
                    .easeInOut(duration: 0.6) :
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)
                ){
                    self.graphData[index].animate = true
                }
            }
        }
    }
}
