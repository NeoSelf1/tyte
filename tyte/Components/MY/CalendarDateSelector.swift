//
//  DateChange.swift
//  tyte
//
//  Created by Neoself on 12/5/24.
//
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
