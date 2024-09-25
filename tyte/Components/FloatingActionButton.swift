import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.gray00)
                .frame(width: 56, height: 56)
                .background(Color.blue30)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}
