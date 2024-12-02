//
//  PopupManager.swift
//  tyte
//
//  Created by Neoself on 12/2/24.
//

import SwiftUI

final class PopupManager: ObservableObject {
    static let shared = PopupManager()
    
    private init() {}
    
    @Published var popupPresented = false
    
    private(set) var currentPopupData: PopupData?
    
    func show(type: PopupType, action: @escaping () -> Void) {
        currentPopupData = PopupData(type: type, action: action)
        popupPresented = true
    }
}


struct PopupViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false
    
    let data: PopupData?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented, let popupData = data {
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                            .opacity(isAnimating ? 0.3 : 0.0)
                            .onTapGesture {
                                if !popupData.type.isMandatory { dismissPopup() }
                            }
                            .animation(.spring(duration: 0.1), value: isAnimating)
                        
                        CustomPopup(
                            hidePopup: dismissPopup,
                            popupData: popupData
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -80)
                        .animation(.spring(duration: 0.3), value: isAnimating)
                    }
                }
            }
            .onChange(of: isPresented) { _, newValue in
                isAnimating = newValue
            }
    }
    
    private func dismissPopup() {
        isPresented = false
        isAnimating = false
    }
}
