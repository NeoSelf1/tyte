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
    @Published var tags: [Tag] = []
    
    /// 날짜수정 메서드가 하위 메서드가 많이 연결되어있는 별도 구조체 내부에 정의되어있어서, 분리하고자 didSet 클로저에 호출
    @Published var currentDate: Date = Date().koreanDate { didSet { getData() } }
    
    @Published var isDetailViewPresent: Bool = false
    @Published var isLoading: Bool = true
    
    @Published var isCalendarMode: Bool = true
    @Published var isGraphPresent: Bool = false
    
    /// calendarView 내부 dayView 클릭시 바텀시트에서 필요 -> 실시간으로 값이 변경되면서 업데이트 필요없기에 @published 제거
    var dailyStatForDate: DailyStat = .empty
    var todosForDate: [Todo] = []
    
    private let syncService = CoreDataSyncService.shared
    
    init() {
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: - Method
    // 친구 요청 조회 및 친구 조회
    func initialize(){
        getData()
        readLocalData(type: .tag, in: currentDate)
    }
    
    func toggleMode(){
        isCalendarMode = !isCalendarMode
        getData()
    }
    
    func selectCalendarDate(date: Date){
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date}) else { return }
        dailyStatForDate = dailyStats[index]
        readLocalData(type: .todo, in: date)
        isDetailViewPresent = true
    }
    
    
    // MARK: - Private Method
    private func getData(){
        isLoading = true
        
        readLocalData(type: .dailyStat, in: currentDate)
        
        syncService.refreshDailyStats(for: String(currentDate.apiFormat.prefix(7)))
            .receive(on: DispatchQueue.main)
            .sink { [weak self]_ in
                self?.isLoading = false
            } receiveValue: {  [weak self] stats in
                self?.dailyStats = stats
                self?.createGraphData(stats: stats)
            }
            .store(in: &cancellables)
        
        if !isCalendarMode {
            isGraphPresent = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                withAnimation { self.isGraphPresent = true }
            }
        }
    }
    
    private func createGraphData(stats:[DailyStat]){
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
    }
    
    private func readLocalData(type: LocalDataType, in date: Date) {
        switch type {
        case .todo:
            if let localTodos = try? syncService.readTodosFromStore(for: date.apiFormat) {
                todosForDate = localTodos
            }
        case .tag:
            if let localTags = try? syncService.readTagsFromStore() {
                tags = localTags
            }
        case .dailyStat:
            if let localDailyStats = try? syncService.readDailyStatsFromStore(for: String(date.apiFormat.prefix(7))) {
                dailyStats = localDailyStats
                createGraphData(stats: localDailyStats)
            }
        default:
            print("edge case")
        }
    }
}
 
