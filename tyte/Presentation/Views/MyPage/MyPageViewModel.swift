import Foundation
import SwiftUI

enum MyPageDataType {
    case monthlyStats(String)  // yearMonth
    case todayStats
    case todos(String)  // date
    case tags
}

/// 마이페이지 화면의 상태와 로직을 관리하는 ViewModel
///
/// 개인화된 통계 데이터를 관리하며 시각화에 필요한 상태를 제공합니다.
///
/// ## 주요 기능
/// - 월별 통계 데이터 관리
/// - 그래프/캘린더 모드 전환
/// - 상세 통계 데이터 처리
///
/// ## 상태 프로퍼티
/// ```swift
/// @Published var dailyStats: [DailyStat]      // 일간 통계
/// @Published var isCalendarMode: Bool         // 캘린더 모드 여부
/// @Published var currentDate: Date            // 현재 선택 날짜
/// ```
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
