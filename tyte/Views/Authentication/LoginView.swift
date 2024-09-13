import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $viewModel.password)
                }
                
                Section {
                    Button(action: viewModel.login) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Log In")
                        }
                    }
                    .disabled(viewModel.isLoginButtonDisabled)
                }
                
                Section {
                    NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn)) {
                        Text("Don't have an account? Sign Up")
                    }
                }
            }
            .navigationTitle("Loginss")
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
            }
            .onChange(of: viewModel.isLoginSuccessful) { success in
                if success {
                    isLoggedIn = true
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
