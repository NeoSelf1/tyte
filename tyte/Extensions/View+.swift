import SwiftUI

extension View {
    func presentToast(
        isPresented: Binding<Bool>,
        data: ToastData?,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            ToastViewModifier(
                isPresented: isPresented,
                data: data,
                onDismiss: onDismiss
            )
        )
    }
    
    func presentPopup(
        isPresented: Binding<Bool>,
        data: PopupData?
    ) -> some View {
        modifier(PopupViewModifier(
            isPresented: isPresented,
            data: data
        ))
    }
    
    func presentOfflineUI(
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(OfflineUIViewModifier(
            isPresented: isPresented
        ))
    }
}
