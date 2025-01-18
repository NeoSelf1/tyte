import SwiftUI

struct StatisticsView: View {
    let dailyStat: DailyStat
    let todos: [Todo]
    
    var body: some View {
        VStack {
            CustomHeaderWithBackBtn(title: "AI 분석리포트",isDoneHidden: true)
            
            DetailSection(
                todosForDate: todos,
                dailyStatForDate: dailyStat,
                isLoading: false
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}
