//
//  StatisticsView.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//
import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    @AppStorage("isDarkMode") private var isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    
    init(selectedDate: Date) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(selectedDate: selectedDate))
    }
    
    var body: some View {
        DetailView(
            todosForDate: viewModel.todosForDate,
            dailyStatForDate: viewModel.dailyStatForDate,
            isLoading: viewModel.isTodoLoading || viewModel.isDailyStatLoading
        )
        .navigationBarTitle("AI 분석리포트", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { presentationMode.wrappedValue.dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
        .onAppear {
            viewModel.fetchInitialData()
        }
    }
}

#Preview {
    StatisticsView(selectedDate: Date().koreanDate)
}
