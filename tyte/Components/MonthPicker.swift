import SwiftUI

struct MonthYearPickerPopup: View {
    @State private var currentYear: Int
    @State private var currentMonth: Int
    @Binding var isShowing: Bool
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    
    init(selectedDate: Binding<Date>, isShowing: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowing = isShowing
        self._currentYear = State(initialValue: calendar.component(.year, from: Date().koreanDate))
        self._currentMonth = State(initialValue: calendar.component(.month, from: Date().koreanDate) - 1)
    }
    
    var body: some View {
        VStack (spacing:0){
            Button(action: {
                withAnimation {
                    isShowing = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(8)
            }
            .frame(maxWidth: .infinity,alignment: .trailing)
            
            HStack {
                Picker("Year", selection: $currentYear) {
                    ForEach(Array(1900...2100), id: \.self) { year in
                        Text(String(year))
                            .foregroundStyle(.gray60)
                            .tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                .clipped()
                
                Picker("Month", selection: $currentMonth) {
                    ForEach(0..<12) { month in
                        Text("\(month+1)월")
                            .foregroundStyle(.gray60)
                            .tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150)
                .clipped()
            }
            
            Button(action: {
                let components = DateComponents(year: currentYear, month: currentMonth + 1, day: 1)
                if let newDate = calendar.date(from: components) {
                    selectedDate = newDate
                }
                withAnimation {
                    isShowing = false
                }
            }) {
                Text("변경하기")
                    .frame(maxWidth: .infinity)
                    .font(._title)
                    .padding()
                    .background(.blue30)
                    .foregroundStyle(.gray00)
                    .cornerRadius(8)
            }
        }
        .frame(width: 300)
        .padding(16)
        .background{
            RoundedRectangle(cornerRadius: 16).fill(.gray00)
        }
    }
}
