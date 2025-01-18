//
//  MyPageViewModel.swift
//  tyte
//
//  Created by 김 형석 on 9/15/24.
//

/// ## 잘못된 예시
/// ```swift
/// @Published var currentDate: Date = Date().koreanDate {
///     didSet { await fetchData(.monthlyStats(currentDate.apiFormat)) }
/// }
/// ```
/// didSet 옵저버는 동기적 컨텍스트이기 때문에 직접 await 사용이 불가합니다.
/// 동기적으로 즉시 반환되고, 비동기 작업은 백그라운드에서 실행됩니다.
/// 따라서, Task 블록을 감싸 동기 컨텍스트로 변경해주어야합니다.

import Foundation
import SwiftUI

enum MyPageDataType {
    case monthlyStats(String)  // yearMonth
    case todayStats
    case todos(String)  // date
    case tags
}

@MainActor
class MyPageViewModel: ObservableObject {
    
    // MARK: - UI State
    
    // 메인 데이터 상태
    @Published var dailyStats: [DailyStat] = []
    @Published var graphData: [DailyStat_Graph] = []
    @Published var tags: [Tag] = []
    
    // 날짜 상태
    @Published var currentDate: Date = Date().koreanDate {
        didSet { Task { await fetchData(.monthlyStats(currentDate.apiFormat)) } }
    }
    
    // UI 컨트롤 상태
    @Published var isDetailSectionPresent: Bool = false
    @Published var isLoading: Bool = true
    @Published var isCalendarMode: Bool = true
    @Published var isGraphPresent: Bool = false
    
    // 세부 정보 상태
    var dailyStatForDate: DailyStat = .empty
    var todosForDate: [Todo] = []
    
    // MARK: - UseCases
    
    private let dailyStatUseCase: DailyStatUseCaseProtocol
    private let todoUseCase: TodoUseCaseProtocol
    private let tagUseCase: TagUseCaseProtocol
    
    init(
        dailyStatUseCase: DailyStatUseCaseProtocol = DailyStatUseCase(),
        todoUseCase: TodoUseCaseProtocol = TodoUseCase(),
        tagUseCase: TagUseCaseProtocol = TagUseCase()
    ) {
        self.dailyStatUseCase = dailyStatUseCase
        self.todoUseCase = todoUseCase
        self.tagUseCase = tagUseCase
        
        initialize()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        Task {
            await fetchData(.monthlyStats(currentDate.apiFormat))
            await fetchData(.tags)
        }
    }
    
    func toggleMode() {
        isCalendarMode.toggle()
        
        if !isCalendarMode {
            isGraphPresent = false
            
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2초 대기
                withAnimation {
                    isGraphPresent = true
                }
            }
        }
    }
    
    func selectCalendarDate(date: Date) {
        guard let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date }) else { return }
        
        dailyStatForDate = dailyStats[index]
        
        Task {
            await fetchData(.todos(date.apiFormat))
            isDetailSectionPresent = true
        }
    }
    
    // MARK: - Private Methods
    
    private func createGraphData(from stats: [DailyStat]) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let startDate = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        
        graphData = (0..<range.count).compactMap { dayOffset -> DailyStat_Graph? in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
                return nil
            }
            
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
    
    private func fetchData(_ dataType: MyPageDataType) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch dataType {
            case .monthlyStats(let date):
                let yearMonth = String(date.prefix(7))
                dailyStats = try await dailyStatUseCase.getMonthStats(in: yearMonth)
                createGraphData(from: dailyStats)
                
            case .todayStats:
                if let todayStat = try await dailyStatUseCase.getTodayStats() {
                    dailyStatForDate = todayStat
                }
                
            case .todos(let date):
                todosForDate = try await todoUseCase.getTodos(in: date)
                
            case .tags:
                tags = try await tagUseCase.getAllTags()
            }
        } catch {
            print("Error fetching \(dataType): \(error)")
        }
    }
}
