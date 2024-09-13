import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $viewModel.username)
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $viewModel.password)
            }
            
            Section {
                Button(action: viewModel.signUp) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Sign Up")
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
        .onChange(of: viewModel.isSignUpSuccessful) { success in
            if success {
                isLoggedIn = true
                dismiss()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(isLoggedIn: .constant(false))
        }
    }
}
