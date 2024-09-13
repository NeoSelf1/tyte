//
//  BottomSheet.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var position: BottomSheetPosition
    let content: Content
    
    init(position: Binding<BottomSheetPosition>, @ViewBuilder content: () -> Content) {
        self._position = position
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray)
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                content
            }
            .frame(height: geometry.size.height)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .offset(y: self.position.offsetFor(geometryProxy: geometry))
            .animation(.spring())
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold = geometry.size.height * 0.3
                        if value.translation.height > threshold {
                            self.position = .partial
                        } else if value.translation.height < -threshold {
                            self.position = .full
                        }
                    }
            )
        }
    }
}

enum BottomSheetPosition {
    case partial
    case full
    
    func offsetFor(geometryProxy: GeometryProxy) -> CGFloat {
        switch self {
        case .partial:
            return geometryProxy.size.height * 0.8
        case .full:
            return geometryProxy.size.height * 0.2
        }
    }
}
//
//#Preview {
//    BottomSheet()
//}
