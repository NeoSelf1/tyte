//
//  DetailView.swift
//  tyte
//
//  Created by 김 형석 on 9/20/24.
//
import Combine
import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel : MyPageViewModel
    
    private var gradientColors: [Color] {
        getColorsForDay(exampleDailyStatForDate) ?? [.gray20]
    }
    
    private let exampleDailyStatForDate = DailyStat(
        id: "66eb72ffa76a69f402f6e3dc",
        date: "2024-09-20",
        user: "66e3f76192082f0bf2b93b13",
        balanceData: tyte.BalanceData(
            title: "극한의 생산성",
            message: "생산성이 절정에 달했어요. 이 페이스를 오래 유지하긴 어려우니 중간중간 휴식을 취하세요.",
            balanceNum: 100),
        productivityNum: 24.53,
        tagStats: [
            tyte.TagStat(
            id: "66ed2e64dfde8972323a6cd0",
            tag: tyte._Tag(
                id: "66e3f87692082f0bf2b93ba4",
                color: "FFF700"),
            count: 4),
                   tyte.TagStat(
                    id: "66ed2e64dfde8972323a6cd1",
                    tag: tyte._Tag(
                        id: "66ecd9770554ca8348dfaf9e",
                        color: "00CED1"),
                    count: 2)],
        center: SIMD2<Float>(0.67165756, 0.27292007)
    )
    private let exampleTodos = [tyte.Todo(id: "66e6866344ac977aac4e347b", user: "66e3f76192082f0bf2b93b13", tagId: Optional(tyte.Tag(id: "66e3f87692082f0bf2b93ba4", name: "개발", color: "FFF700", user: "66e3f76192082f0bf2b93b13")), raw: "커스텀탭바 구현!", title: "커스텀탭바 구현", isImportant: true, isLife: false, difficulty: 5, estimatedTime: 260, deadline: "2024-09-18", isCompleted: true), tyte.Todo(id: "66e9c2db1d5009348ba6819d", user: "66e3f76192082f0bf2b93b13", tagId: Optional(tyte.Tag(id: "66e3f7b492082f0bf2b93b23", name: "가족", color: "FF0000", user: "66e3f76192082f0bf2b93b13")), raw: "일정 다시 정리하기", title: "일정 다시 정리하기", isImportant: false, isLife: true, difficulty: 2, estimatedTime: 60, deadline: "2024-09-18", isCompleted: true), tyte.Todo(id: "66e665fd44ac977aac4e3185", user: "66e3f76192082f0bf2b93b13", tagId: Optional(tyte.Tag(id: "66e3f87692082f0bf2b93ba4", name: "개발", color: "FFF700", user: "66e3f76192082f0bf2b93b13")), raw: "날짜 선택 로직 수정", title: "날짜 선택 로직 수정", isImportant: false, isLife: false, difficulty: 3, estimatedTime: 120, deadline: "2024-09-18", isCompleted: true)]
    
    var body: some View {
        ZStack {
            MeshGradientView(colors: gradientColors, center: exampleDailyStatForDate.center, isSelected: true)
                .frame(width: 300,height: 300)
            
            VStack{
                HStack{
                    Text(exampleDailyStatForDate.date)
                        .font(._subhead1)
                        .foregroundStyle(.gray90)
                    
                    Spacer()
                    
                    Text(exampleDailyStatForDate.balanceData.message)
                        .font(._subhead2)
                        .foregroundStyle(.gray60)
                }
                Spacer()
                
                HStack(alignment: .bottom){
                    Text("\(exampleDailyStatForDate.productivityNum)")
                        .font(._subhead1)
                        .foregroundStyle(.gray90)
                    
                    Spacer()
                    
                    VStack{
                        ForEach(viewModel.tags){ tag in
                            HStack (spacing:8){
                                Circle().fill(Color(hex: "#\(tag.color)"))
                                    .frame(width: 6,height: 6)
                                
                                Text(tag.name)
                                    .font(._body3)
                                    .foregroundStyle(.gray60)
                            }
                        }
                    }
                }
            }
            .frame(width: 300*1.3,height: 300*1.3)
        }
    }
}


#Preview {
    DetailView(viewModel: MyPageViewModel())
}
