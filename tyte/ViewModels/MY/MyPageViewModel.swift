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
    // calendarView 내부 dayView 클릭시 바텀시트에서 필요 -> 실시간으로 값이 변경되면서 업데이트 필요없기에 @published 제거
    var dailyStatForDate: DailyStat = .empty
    
    @Published var dailyStats: [DailyStat] = []
    @Published var graphData: [DailyStat_Graph] = []
    @Published var currentDate: Date = Date().koreanDate { didSet {
        getCalendarAndGraphData(in:String(currentDate.apiFormat.prefix(7)))
    } }
    
    @Published var todosForDate: [Todo] = []
    @Published var currentTab: Int = 0
    
    @Published var isDetailViewPresent: Bool = false
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
        
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    // 친구 요청 조회 및 친구 조회
    func initialize(){
        getCalendarAndGraphData(in: String(Date().koreanDate.apiFormat.prefix(7)))
    }
    
    func selectCalendarDate(date: Date) {
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date}) else {return}
        isLoading = true
        dailyStatForDate = dailyStats[index]
        
        todoService.fetchTodos(for: date.apiFormat)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                todosForDate = todos
                isDetailViewPresent = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Method
    // TODO: Index out of range 버그 수정하기
    private func getCalendarAndGraphData(in yearMonth: String){
        isLoading = true
        dailyStatService.fetchMonthlyStats(in: yearMonth)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else {return}
            isLoading = false
            if case .failure(let error) = completion {
                appState.showToast(.error(error.localizedDescription))
            }
        } receiveValue: { [weak self] stats in
            guard let self = self else { return }
            dailyStats = stats
            
            let calendar = Calendar.current
            let startDate: Date = calendar.date(byAdding: .month, value: -1, to: currentDate)!
            let dateRange = calendar.dateComponents([.day], from: startDate, to: currentDate).day! + 1
            
            graphData = (0..<dateRange).compactMap { dayOffset -> DailyStat_Graph? in
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { return nil }
                
                // Graph의 경우, animate 속성값 및 데이터가 없는 날짜에 대한 더미데이터 생성이 필요하므로 필요한 필드로만 구성된 새로운 struct인 DailyStat_Graph 추가
                if let existingStat = stats.first(where: { $0.date == date.apiFormat }) {
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
