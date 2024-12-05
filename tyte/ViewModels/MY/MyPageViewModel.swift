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
    
    @Published var dailyStats: [DailyStat] = []
    @Published var graphData: [DailyStat_Graph] = []
    
    /// 날짜수정 메서드가 하위 메서드가 많이 연결되어있는 별도 구조체 내부에 정의되어있어서, 분리하고자 didSet 클로저에 호출
    @Published var currentDate: Date = Date().koreanDate { didSet { getData() } }
    
    @Published var isDetailViewPresent: Bool = false
    @Published var isLoading: Bool = true
    @Published var isCalendarMode: Bool = false
    @Published var isGraphPresent: Bool = false
    /// calendarView 내부 dayView 클릭시 바텀시트에서 필요 -> 실시간으로 값이 변경되면서 업데이트 필요없기에 @published 제거
    var dailyStatForDate: DailyStat = .empty
    var todosForDate: [Todo] = []
    
    private let dailyStatService: DailyStatServiceProtocol
    private let todoService: TodoServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        dailyStatService: DailyStatServiceProtocol = DailyStatService(),
        authService: AuthServiceProtocol = AuthService(),
        todoService: TodoServiceProtocol = TodoService()
    ) {
        self.dailyStatService = dailyStatService
        self.authService = authService
        self.todoService = todoService
        
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    // 친구 요청 조회 및 친구 조회
    func initialize(){
        getData()
    }
    
    func toggleMode(){
        isCalendarMode = !isCalendarMode
        getData()
    }
    
    func selectCalendarDate(date: Date) {
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date}) else { return }
        isLoading = true
        dailyStatForDate = dailyStats[index]
        
        todoService.fetchTodos(for: date.apiFormat)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                todosForDate = todos
                isDetailViewPresent = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Method
    private func getData(){
        isLoading = true
        let todayYearMonth = currentDate.apiFormat.prefix(7)
        dailyStatService.fetchMonthlyStats(in: String(todayYearMonth))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                
                if !isCalendarMode {
                    isGraphPresent = false
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month], from: currentDate)
                    let startDate = calendar.date(from: components)!
                    let range = calendar.range(of: .day, in: .month, for: currentDate)!
                    
                    graphData = (0..<range.count).compactMap { dayOffset -> DailyStat_Graph? in
                        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { return nil }
                        
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        withAnimation{ self.isGraphPresent = true }
                    }
                } else {
                    withAnimation{ self.dailyStats = stats }
                }
            }
            .store(in: &cancellables)
    }
}
 
