/// 특정 날짜의 상세 통계와 완료된 할 일 목록을 표시하는 상세 뷰 컴포넌트
///
/// MeshGradient를 활용한 프리즘 효과, 생산성 지수, 워라밸 상태,
/// 완료된 할 일 목록 등을 포함한 종합적인 일일 리포트를 제공합니다.
///
/// - Parameters:
///   - todosForDate: 해당 날짜의 할 일 목록
///   - dailyStatForDate: 해당 날짜의 통계 데이터
///   - isLoading: 로딩 상태 표시 여부
///
/// - Note: 다음 뷰에서 사용됩니다:
///   - HomeView와 SocialView: 날짜 선택 시 바텀시트로 표시
///   - MyPageView: AI 분석 보기 선택 시 전체 화면으로 표시
import Combine
import SwiftUI

struct DetailSection: View {
    let todosForDate: [Todo]
    let dailyStatForDate: DailyStat
    let isLoading: Bool

    @State private var showingSavedAlert = false
    @State private var balance: (workPercentage: Double, lifePercentage: Double) = (50, 50)
    @State private var productivityNum: Double = 0

    private let prismSize: CGFloat = 240
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                versionNoticeSection
                
                if isLoading {
                    ProgressView()
                        .tint(.gray50)
                        .frame(height: 56)
                } else {
                    prismSection
                    adviceSection
                    workLifeBalanceSection
                    completedTodosSection
                }
            }
            .padding()
        }
        .background(.gray00)
    }
}


// MARK: - Main View Components

extension DetailSection {
    @ViewBuilder
    private var versionNoticeSection: some View {
        if #unavailable(iOS 18.0) {
            HStack {
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
            Spacer().frame(height: 12)
        }
    }
    
    private var prismSection: some View {
        ZStack {
            MeshGradientCell(
                colors: getColors(dailyStatForDate),
                center: dailyStatForDate.center,
                isSelected: true,
                cornerRadius: 32
            )
            .frame(width: prismSize, height: prismSize)
            
            VStack {
                prismHeader
                Spacer()
                prismFooter
            }
        }
        .frame(maxWidth: .infinity, maxHeight: prismSize * 1.18)
    }
    
    private var adviceSection: some View {
        VStack(spacing: 4) {
            Text("이날의 조언")
                .font(._body2)
                .foregroundStyle(.gray60)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(dailyStatForDate.balanceData.message)
                .font(._subhead2)
                .foregroundStyle(.gray50)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var workLifeBalanceSection: some View {
        WorkLifeBalanceBarView(balance: $balance, todosForDate: todosForDate)
    }
    
    private var completedTodosSection: some View {
        VStack(spacing: 4) {
            completedTodosHeader
            completedTodosList
        }
    }
}


// MARK: - 컴포넌트 변수

extension DetailSection {
    private var prismHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dailyStatForDate.date.parsedDate.formattedYear)
                    .font(._title)
                    .foregroundStyle(.gray90)
                
                Text(dailyStatForDate.date.parsedDate.formattedMonthDate)
                    .font(._headline2)
                    .foregroundStyle(.gray90)
            }
            
            Spacer()
            
            Image("logo")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray90)
                .padding(6)
                .opacity(0.8)
                .frame(height: 44)
        }
    }
    
    private var prismFooter: some View {
        HStack(alignment: .bottom) {
            productivitySection
            Spacer()
            tagStatsSection
        }
    }
    
    private var productivitySection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("이날의 생산지수")
                .font(._caption)
                .foregroundStyle(.gray60)
            
            Text(productivityNum.formatted())
                .font(._headline1)
                .foregroundStyle(.gray90)
                .contentTransition(.numericText(value: productivityNum))
                .animation(.snappy, value: productivityNum)
                .onAppear {
                    productivityNum = dailyStatForDate.productivityNum
                }
        }
    }
    
    private var tagStatsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(dailyStatForDate.tagStats) { tagStat in
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
    
    private var completedTodosHeader: some View {
        HStack {
            Text("완료한 Todo들")
                .font(._body2)
                .foregroundStyle(.gray60)
            
            Text("\(todosForDate.filter { $0.isCompleted }.count)개")
                .font(._body3)
                .foregroundStyle(.gray50)
            
            Spacer()
        }
    }
    
    private var completedTodosList: some View {
        ForEach(todosForDate.filter { $0.isCompleted }) { todo in
            TodoItem(
                todo: todo,
                isPast: true,
                isButtonPresent: false,
                onToggle: {},
                onSelect: {}
            )
            .padding(4)
        }
    }
}


// MARK: - 워라벨 수치 표시 바 컴포넌트

private struct WorkLifeBalanceBarView: View {
    @Binding var balance: (workPercentage: Double, lifePercentage: Double)
    let todosForDate: [Todo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("워라벨")
                .font(._body2)
                .foregroundStyle(.gray60)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "#FFA500"))
                        .frame(width: CGFloat(balance.workPercentage) / 100 * geometry.size.width)
                    Rectangle()
                        .fill(.blue30.gradient)
                        .frame(width: CGFloat(balance.lifePercentage) / 100 * geometry.size.width)
                }
            }
            .frame(height: 4)
            .cornerRadius(10)
            
            balanceIndicators
        }
        .onAppear {
            withAnimation(.longEaseInOut) {
                balance = calculateDailyBalance(for: todosForDate)
            }
        }
    }
    
    private var balanceIndicators: some View {
        HStack {
            workIndicator
            Spacer()
            lifeIndicator
        }
    }
    
    private var workIndicator: some View {
        HStack {
            Circle()
                .fill(Color(hex: "#FFA500"))
                .frame(width: 8, height: 8)
            Text("일 \(String(format: "%.1f", balance.workPercentage))%")
                .font(._caption)
                .foregroundStyle(.gray50)
        }
    }
    
    private var lifeIndicator: some View {
        HStack {
            Circle()
                .fill(.blue30)
                .frame(width: 8, height: 8)
            Text("생활 \(String(format: "%.1f", balance.lifePercentage))%")
                .font(._caption)
                .foregroundStyle(.gray50)
        }
    }
}
