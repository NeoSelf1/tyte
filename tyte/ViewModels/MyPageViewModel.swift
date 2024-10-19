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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var dailyStats: [DailyStat] = []
    @Published var graphData: [DailyStat_Graph] = []
    @Published var selectedDate: Date = Date().koreanDate
    @Published var dailyStatForDate: DailyStat?
    @Published var todosForDate: [Todo] = []
    
    @Published var currentMonth: Date = Date().koreanDate
    
    @Published var isDetailViewPresented: Bool = false
    
    @Published var currentTab: Int = 0
    @Published var graphRange: String = "week" {
        didSet {
            fetchDailyStats()
        }
    }
    
    private let dailyStatService: DailyStatService
    private let todoService: TodoService
    private let authService: AuthService
    
    private var cancellables = Set<AnyCancellable>()

    init(
        dailyStatService: DailyStatService = DailyStatService.shared,
        authService: AuthService = AuthService.shared,
        todoService: TodoService = TodoService.shared
    ) {
        print("MyPageViewModel init")
        self.dailyStatService = dailyStatService
        self.todoService = todoService
        self.authService = authService
        self.fetchDailyStats()
    }
    
    func selectDateForInsightData(date: Date) {
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date}) else {return}
        dailyStatForDate = dailyStats[index]
        fetchTodosForDate(date.apiFormat)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        isLoading = true
        errorMessage = nil
        todoService.fetchTodosForDate(deadline: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.isLoading = false
                guard let self = self else { return }
                self.todosForDate = todos
                isDetailViewPresented = true
            }
            .store(in: &cancellables)
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
                dailyStats = _dailyStats
                
                let dateRange = calendar.dateComponents([.day], from: startDate, to: currentDate).day! + 1
                graphData = (0..<dateRange).compactMap { dayOffset -> DailyStat_Graph? in
                    guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { return nil }
                    
                    // MARK: Graph의 경우, animate 속성값 및 데이터가 없는 날짜에 대한 더미데이터 생성이 필요하므로 필요한 필드로만 구성된 새로운 struct인 DailyStat_Graph 추가
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
                animateGraph()
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
