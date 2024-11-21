//
//  StatisticsView.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//
import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    let dailyStat: DailyStat
    let todos: [Todo]
    
    var body: some View {
        DetailView(
            todosForDate: todos,
            dailyStatForDate: dailyStat,
            isLoading: false
        )
        .navigationBarTitle("AI 분석리포트", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
    }
}
