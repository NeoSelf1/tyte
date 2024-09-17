import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button(action: {
                        viewModel.login(email: email, password: password)
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Log In")
                        }
                    }
                    .disabled(isLoginButtonDisabled)
                }
                
                Section {
                    NavigationLink(destination: SignUpView(viewModel: viewModel)) {
                        Text("Don't have an account? Sign Up")
                    }
                }
            }
            .navigationTitle("로그인")
//            .alert(item: Binding(
//                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
//                set: { _ in viewModel.errorMessage = nil }
//            )) { alertItem in
//                Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
//            }
        }
    }
    
    private var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || viewModel.isLoading
    }
}
