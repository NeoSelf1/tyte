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
    @State private var isAnimating = false
    @State private var balance : (workPercentage:Double, lifePercentage:Double) = (50,50)
    @State private var productivityNum : Double = 0
    @State private var showingSavedAlert = false
    
    private let prismSize :CGFloat = 240
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack (spacing: 12) {
                if #unavailable(iOS 18.0) {
                    HStack{
                        Text("iOS 18버전으로 업데이트 시, 더 생생한 프리즘을 볼 수 있어요")
                            .font(._body3)
                            .foregroundColor(.gray50)
                        Spacer()
                    }
                        .padding()
                        .background(.gray10)
                        .cornerRadius(8)
                        .padding(.horizontal)
                } else {
                    Spacer().frame(height:12)
                }
                
                if let dailyStat = viewModel.dailyStatForDate {
                    ZStack {
                        MeshGradientView(
                            colors: getColors(dailyStat),
                            center: dailyStat.center,
                            isSelected: true,
                            cornerRadius: 32
                        ).frame(width: prismSize, height: prismSize)
                        
                        VStack {
                            HStack{
                                VStack(alignment: .leading){
                                    Text(dailyStat.date.parsedDate.formattedYear)
                                        .font(._title)
                                        .foregroundStyle(.gray90)
                                    
                                    Text(dailyStat.date.parsedDate.formattedMonthDate)
                                        .font(._headline2)
                                        .foregroundStyle(.gray90)
                                }
                                Spacer()
                                
                                Image(colorScheme == .dark ? "logo-dark" : "logo-light")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(6)
                                    .opacity(0.8)
                                    .frame(height:44)
                            }
                            
                            Spacer()
                            
                            HStack(alignment: .bottom){
                                VStack (alignment:.leading, spacing:2){
                                    Text("이날의 생산지수")
                                        .font(._caption)
                                        .foregroundStyle(.gray60)
                                    
                                    Text(productivityNum.formatted())
                                        .font(._headline1)
                                        .foregroundStyle(.gray90)
                                        .contentTransition(.numericText(value: productivityNum))
                                        .animation(.snappy,value: productivityNum)
                                        .onAppear{
                                            productivityNum = dailyStat.productivityNum
                                        }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("태그 목록")
                                        .font(._caption)
                                        .foregroundStyle(.gray60)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(dailyStat.tagStats) { tagStat in
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(Color(hex: tagStat.tag.color))
                                                    .frame(width: 6, height: 6)
                                                    .overlay(Circle().stroke(.gray50))
                                                
                                                Text(tagStat.tag.name)
                                                    .font(._body3)
                                                    .foregroundColor(.gray60)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(width:.infinity, height: prismSize*1.18)
                    
                    VStack(spacing:4){
                        Text("이날의 조언")
                            .font(._body3)
                            .foregroundStyle(.gray60)
                            .padding(.leading,2)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        
                        Text(dailyStat.balanceData.message)
                            .font(._subhead2)
                            .foregroundStyle(.gray50)
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }
                    
                    WorkLifeBalanceBar(balance:balance)
                        .onAppear{
                            withAnimation(.longEaseInOut) {
                                balance = calculateDailyBalance(for: viewModel.todosForDate)
                            }
                        }
                    
                    VStack(spacing:4){
                        HStack{
                            Text("완료한 Todo들")
                                .font(._body3)
                                .foregroundStyle(.gray60)
                                .padding(.leading,2)
                            
                            Text("\(viewModel.todosForDate.filter{$0.isCompleted==true}.count)개")
                                .font(._body3)
                                .foregroundStyle(.gray50)
                            Spacer()
                        }
                        
                        ForEach(viewModel.todosForDate.filter{$0.isCompleted==true}) { todo in
                            TodoItemView(todo: todo, isHome: false)
                                .opacity(0.6)
                                .padding(4)
                        }
                    }
                } else {
                    Text("선택된 날짜의 데이터가 없습니다.")
                        .font(._headline2)
                }
            }
            .padding()
        }
        .background(.gray00)
    }
}


