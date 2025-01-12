import SwiftUI

struct StatisticsView: View {
    let dailyStat: DailyStat
    let todos: [Todo]
    
    var body: some View {
        VStack {
            CustomHeaderWithBackBtn(title: "AI 분석리포트")
            
            DetailView(
                todosForDate: todos,
                dailyStatForDate: dailyStat,
                isLoading: false
            )
        }
    }
}
