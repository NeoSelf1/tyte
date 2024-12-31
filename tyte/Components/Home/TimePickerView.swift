//
//  TimePickerView.swift
//  tyte
//
//  Created by Neoself on 12/24/24.
//
import SwiftUI

struct TimePickerView: View {
    @Binding var estimatedTime: Int
    
    var body: some View {
        VStack {
            NavigationBar(title: "소요시간 수정")
            
            Spacer()
            
            Text(estimatedTime.formattedDuration)
                .font(._subhead1)
                .foregroundColor(.gray90)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentTransition(.numericText(value: Double(estimatedTime)))
                .animation(.snappy, value: estimatedTime)
            
            TimeWheelPicker(value: Binding<CGFloat>(
                get: { CGFloat(estimatedTime) },
                set: { newValue in
                    estimatedTime = Int(round(newValue))
                }
            ))
            
            Spacer()
        }
        .background(.gray00)
        
        .navigationBarBackButtonHidden(true)
    }
}

struct TimeWheelPicker: View {
    private let count:Int = 8
    private let spacing:CGFloat = 30
    private let multiplier:Int = 10
    private let steps:Int = 6
    
    @Binding var value: CGFloat
    @State private var isLoaded: Bool = false
    @State private var scrollID: Int?
    
    var body: some View {
        VStack{
            GeometryReader { geometry in
                let horizontalPadding = geometry.size.width / 2
                
                ScrollView(.horizontal) {
                    HStack(spacing: spacing) {
                        let totalSteps = steps * count + 1
                        
                        ForEach(1..<totalSteps, id: \.self) { index in
                            let remainder = index % steps
                            
                            Divider()
                                .background(remainder == 0 ? .gray90 : .gray50)
                                .frame(width: 4, height: remainder == 0 ? 80 : 50, alignment: .center)
                                .frame(maxHeight: 80, alignment: .top)
                                .overlay(alignment: .bottom) {
                                    if remainder == 0 {
                                        Text(((index / steps) * multiplier * 6).formattedDuration)
                                            .font(._body1)
                                            .foregroundColor(.gray60)
                                            .fixedSize()
                                            .offset(y: 32)
                                    }
                                }
                        }
                    }
                    .frame(height: geometry.size.height)
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .onChange(of: scrollID) { oldValue, newValue in
                    if let newValue {
                        value = (CGFloat(newValue) / CGFloat(steps)) * CGFloat(multiplier) * 6
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .overlay(alignment: .center) {
                    Rectangle()
                        .frame(width: 1, height: 80)
                        .padding(.bottom, 50)
                }
                .safeAreaPadding(.horizontal, horizontalPadding)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollID = Int(value) * steps / (multiplier * 6)
                        isLoaded = true
                    }
                }
            }
        }
        .frame(height: 280)
    }
}

//#Preview("TimePickerView") {
////    NavigationStack {
//        TimePickerView(estimatedTime: .constant(30))
//            .frame(maxHeight: 520)
//            .border(.gray50)
////    }
//}
