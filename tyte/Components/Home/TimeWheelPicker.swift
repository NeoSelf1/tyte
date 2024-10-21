import SwiftUI

struct TimeWheelPicker: View {
    private let count:Int = 8
    private let spacing:CGFloat = 20
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
                                .frame(width: 2, height: remainder == 0 ? 20 : 10, alignment: .center)
                                .frame(maxHeight: 20, alignment: .bottom)
                                .overlay(alignment: .bottom) {
                                    if remainder == 0 {
                                        Text(((index / steps) * multiplier * 6).formattedDuration)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray60)
                                            .fixedSize()
                                            .offset(y: 20)
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
                    }
                }
                .overlay(alignment: .center) {
                    Rectangle()
                        .frame(width: 1, height: 40)
                        .padding(.bottom, 20)
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
    }
}
