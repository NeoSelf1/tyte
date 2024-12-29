//
//  ToastManager 2.swift
//  tyte
//
//  Created by Neoself on 12/28/24.
//


//
//  ToastManager.swift
//  tyte
//
//  Created by Neoself on 12/2/24.
//

import SwiftUI

final class OfflineUIManager: ObservableObject {
    static let shared = OfflineUIManager()
    
    private init() {}
    
    @Published var offlineUIPresented: Bool = false
    
    func show() {
        offlineUIPresented = true
    }
    
    func hide() {
        offlineUIPresented = false
    }
}

struct OfflineUIViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomLeading) {
                if isPresented {
                    Image(systemName: "network.slash")
                        .resizable()
                        .frame(width: 24,height:24)
                        .foregroundColor(.red)
                        .padding(.leading, 24)
                        .padding(.bottom, 112)
                        .opacity(isAnimating ? 1 : 0.6)
                        .animation(
                            .longEaseInOut
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            withAnimation { isAnimating = true }
                        }
                }
            }
    }
}
