import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }
            
            Section {
                Button(action: {
                    viewModel.signUp(username: username, email: email, password: password)
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                    }
                }
                .disabled(isSignUpButtonDisabled)
            }
        }
        .navigationTitle("Sign Up")
        .alert(item: $viewModel.errorMessage) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private var isSignUpButtonDisabled: Bool {
        username.isEmpty || email.isEmpty || password.isEmpty || viewModel.isLoading
    }
}
