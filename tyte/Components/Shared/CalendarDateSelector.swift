/// 월별 캘린더의 날짜 이동을 담당하는 네비게이션 컴포넌트
///
/// 이전/다음 월로 이동할 수 있는 버튼과 현재 월을 표시하는 텍스트로 구성됩니다.
/// 이전 12개월과 현재 날짜 이후로의 이동이 제한됩니다.
///
/// - Note: HomeView와 MyPageView의 상단 월 선택 영역에서 사용됩니다.
/// - Important: 버튼 중복 클릭 방지를 위한 디바운스 로직이 포함되어 있습니다.
import SwiftUI

struct CalendarDateSelector: View {
    @Binding var currentMonth: Date
    @State private var isButtonEnabled = true
    
    var body: some View{
        HStack(alignment: .center, spacing: 24) {
            Button(
                action: {
                    changeMonth(by: -1)
                    debounceButton()
                },
                label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 16)
                        .padding()
                        .foregroundColor(canMoveToPreviousMonth() ? .gray90 : . gray30)
                }
            )
            .disabled(!canMoveToPreviousMonth() || !isButtonEnabled)
            
            Text(currentMonth.formattedMonth)
                .font(._subhead1)
                .foregroundStyle(.gray90)
            
            Button(
                action: {
                    changeMonth(by: 1)
                    debounceButton()
                },
                label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 10, height: 16)
                        .padding()
                        .foregroundColor(canMoveToNextMonth() ? .gray90 : .gray30)
                }
            )
            .disabled(!canMoveToNextMonth() || !isButtonEnabled)
        }
    }
    
    // MARK: - Private Methods
    private func debounceButton() {
        isButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isButtonEnabled = true
        }
    }
    
    /// 월 변경
    private func changeMonth(by value: Int) {
        currentMonth = adjustedMonth(by: value)
    }
    
    /// 이전 월로 이동 가능한지 확인
    private func canMoveToPreviousMonth() -> Bool {
        let currentDate = Date().koreanDate
        let calendar = Calendar.current
        let targetDate = calendar.date(byAdding: .month, value: -12, to: currentDate) ?? currentDate
        
        if adjustedMonth(by: -1) < targetDate {
            return false
        }
        return true
    }
    
    /// 다음 월로 이동 가능한지 확인
    private func canMoveToNextMonth() -> Bool {
        let currentDate = Date().koreanDate
        
        if adjustedMonth(by: 1) > currentDate {
            return false
        }
        return true
    }
    
    /// 변경하려는 월 반환
    private func adjustedMonth(by value: Int) -> Date {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            return newMonth
        }
        return currentMonth
    }
}
