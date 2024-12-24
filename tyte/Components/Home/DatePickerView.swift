//
//  DatePickerView.swift
//  tyte
//
//  Created by Neoself on 12/24/24.
//
import SwiftUI

struct DatePickerView: View {
    @Binding var deadline: String
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), day: calendar.component(.day, from: Date()))
        let startDate = calendar.date(from: startComponents)!
        
        let endComponents = DateComponents(year: calendar.component(.year, from: Date()) + 1, month: 12, day: 31)
        let endDate = calendar.date(from: endComponents)!
        
        return startDate...endDate
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(title: "마감일자 수정")
            
            DatePicker(
                "마감일",
                selection: Binding(
                    get: { deadline.parsedDate },
                    set: { deadline = $0.apiFormat }
                ),
                in: dateRange,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .padding()
            
            Spacer()
        }
        .background(.gray00)
        
        .navigationBarBackButtonHidden(true)
    }
}
