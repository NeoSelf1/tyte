//
//  ToastManager.swift
//  tyte
//
//  Created by Neoself on 12/2/24.
//

import SwiftUI

final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    private init() {}
    
    @Published var toastPresented = false
    
    private(set) var currentToastData: ToastData?
    
    func show(_ type: ToastType, action: (() -> Void)? = nil) {
        currentToastData = ToastData(type: type, action:action)
        toastPresented = true
    }
}

struct ToastViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    let data: ToastData?
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let data = data, isPresented {
                    CustomToast(toastData: data)
                        .padding(.top, 40)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -80)
                        .animation(.spring(duration: 0.5), value: isAnimating)
                        .onAppear {
                            withAnimation { isAnimating = true }
                            
                            withAnimation(.spring.delay(2)) {
                                isAnimating = false
                                isPresented = false
                                onDismiss?()
                            }
                        }
                }
            }
    }
}
