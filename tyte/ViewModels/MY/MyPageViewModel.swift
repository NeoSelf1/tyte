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
    private let appState: AppState
    
    @Published var dailyStats: [DailyStat] = []
    @Published var graphData: [DailyStat_Graph] = []
    @Published var selectedDate: Date = Date().koreanDate
    @Published var dailyStatForDate: DailyStat = .initial
    @Published var currentMonth: Date = Date().koreanDate
    @Published var todosForDate: [Todo] = []
    
    @Published var currentTab: Int = 0
    
    @Published var isDetailViewPresented: Bool = false
    @Published var isLoading: Bool = true
    
    private let dailyStatService: DailyStatServiceProtocol
    private let todoService: TodoServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        dailyStatService: DailyStatServiceProtocol = DailyStatService(),
        authService: AuthServiceProtocol = AuthService(),
        todoService: TodoServiceProtocol = TodoService(),
        appState: AppState = .shared
    ) {
        self.dailyStatService = dailyStatService
        self.todoService = todoService
        self.authService = authService
        self.appState = appState
        
        self.fetchDailyStats()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    func selectDateForInsightData(date: Date) {
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date}) else {return}
        dailyStatForDate = dailyStats[index]
        fetchTodosForDate(date.apiFormat)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        todoService.fetchTodos(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
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
        let calendar = Calendar.current
        let currentDate = Date().koreanDate
        dailyStatService.fetchMonthlyStats(yearMonth: String(currentDate.apiFormat.prefix(7)))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] _dailyStats in
                guard let self = self else { return }
                dailyStats = _dailyStats
                var startDate: Date = calendar.date(byAdding: .month, value: -1, to: currentDate)!
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
    
    func animateGraph(){
        for (index,_) in graphData.enumerated(){
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (0.03)){
                // 현재 BlendDuration은 어떠한 시각적 효과가 없음.
                withAnimation( .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.3) ){
                    self.graphData[index].animate = true
                }
            }
        }
    }
}
