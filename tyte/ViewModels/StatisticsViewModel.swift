//
//  StatisticsViewModel.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//

import Foundation
import Combine
import Alamofire
import SwiftUI

class StatisticsViewModel: ObservableObject {
    let appState = AppState.shared
    
    @Published var todosForDate: [Todo] = []
    @Published var dailyStatForDate: DailyStat = dummyDailyStat
    
    private let selectedDate: Date
    private let todoService: TodoServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    
    @Published var isDailyStatLoading: Bool = true
    @Published var isTodoLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        selectedDate: Date,
        dailyStatService: DailyStatServiceProtocol = DailyStatService(),
        todoService: TodoServiceProtocol = TodoService()
    ) {
        self.selectedDate = selectedDate
        self.dailyStatService = dailyStatService
        self.todoService = todoService
    }
    
    func fetchInitialData() {
        let dateString = selectedDate.apiFormat
        fetchTodosForDate(dateString)
        fetchDailyStatForDate(dateString)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    private func fetchTodosForDate(_ deadline: String) {
        todoService.fetchTodos(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    self.appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                isTodoLoading = false
                todosForDate = todos
            }
            .store(in: &cancellables)
    }
    
    private func fetchDailyStatForDate(_ deadline: String) {
        dailyStatService.fetchDailyStat(for: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] dailyStat in
                guard let self = self else { return }
                isDailyStatLoading = false
                dailyStatForDate = dailyStat
            }
            .store(in: &cancellables)
    }
}
