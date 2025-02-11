import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    @EnvironmentObject var appState: AppState
    
    @FocusState private var focusedField: Field?
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }
            
            VStack(spacing: 8) {
                if !viewModel.isSignUp {
                    thumbnail
                    loginSection
                        .onAppear { focusedField = Field.password }
                } else {
                    signUpSection
                        .onAppear { focusedField = Field.username }
                }
            }
            .padding(.horizontal)
        }
        .animation(.mediumEaseInOut,value: viewModel.errorText)
        .animation(.mediumEaseInOut,value: viewModel.isSignUp)
        
        .animation(.fastEaseInOut,value: viewModel.isEmailInvalid)
        .animation(.fastEaseInOut,value: viewModel.isPasswordInvalid)
        .animation(.fastEaseInOut,value: viewModel.isUsernameInvalid)
        
        .animation(.fastEaseInOut,value: viewModel.isExistingUser)
        .animation(.fastEaseInOut,value: viewModel.isPasswordWrong)
        
        .onAppear{
            viewModel.isSignUp = false
            viewModel.isExistingUser = false
        }
    }

    private var thumbnail: some View {
        VStack {
            Image("logo-transparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
                .padding(.bottom,8)
            
            Image("logo")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray90)
                .frame(height:24)
            
            Text("일상의 균형과 생산성을 높이는 스마트한\nTodo 어플리케이션")
                .font(._title)
                .foregroundStyle(.gray60)
                .multilineTextAlignment(.center)
                .frame(height:48)
                .padding(.top,8)
        }
    }
    
    private var loginSection: some View {
        VStack {
            Text(viewModel.errorText)
                .font(._body3)
                .foregroundColor(.red).opacity(0.7)
                .frame(maxWidth: .infinity,maxHeight:32, alignment: .bottomLeading)
                .padding(.top,24)
            
            CustomTextField(
                text: $viewModel.email,
                placeholder: "이메일",
                keyboardType: .emailAddress,
                onSubmit: { viewModel.submit() }
            )
            .focused($focusedField, equals: .email)
            .padding(.bottom,4)
            
            if viewModel.isExistingUser {
                SecureField("",
                            text: $viewModel.password,
                            prompt: Text("비밀번호")
                    .foregroundColor(.gray50)
                )
                .focused($focusedField, equals: .password)
                .foregroundColor(.gray90)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.isPasswordWrong ? .red.opacity(0.1) : .gray10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue10, lineWidth: 1)
                )
                .offset(x: shakeOffset)
                .onChange(of: viewModel.isPasswordWrong) { _, newValue in
                    if newValue {
                        withAnimation(.snappy(duration: 0.13, extraBounce: 0).speed(1.5).repeatCount(3)) {
                            shakeOffset = 8
                        } completion: {
                            shakeOffset = 0
                        }
                    }
                }
            }
            
            CustomButton(
                action: viewModel.submit,
                isLoading: viewModel.isLoading,
                text: viewModel.isExistingUser ? "로그인하기" : "이메일로 시작하기",
                isDisabled: viewModel.isButtonDisabled
            )
            .padding(.top,4)
            
            HStack {
                VStack { Divider() }.padding(.horizontal, 20)
                Text("또는")
                    .foregroundColor(.gray60)
                    .font(._caption)
                VStack { Divider() }.padding(.horizontal, 20)
            }
            .padding(.vertical,12)
            
            googleButton
            appleButton
            
            Button(action:{
                appState.isGuestMode=true
            }){
                Text("게스트모드로 시작하기")
                    .font(._body4)
                    .foregroundStyle(.gray50)
                    .overlay(Rectangle()
                        .fill(.gray30)
                        .frame(height: 1)
                        .offset(y: 2),alignment: .bottom)
            }
            .frame(maxWidth: .infinity,alignment: .center)
            .padding(.top,12)
        }
    }
    
    private var signUpSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("균형 잡힌 하루를 만들어갈\n당신을 환영합니다")
                .font(._headline1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 64)
                .padding(.top,24)
            
            Text(viewModel.errorText)
                .font(._body3)
                .foregroundColor(.red).opacity(0.7)
                .frame(maxWidth: .infinity, maxHeight: 56, alignment: .bottomLeading)
                .padding(.top,32)
            
            CustomTextField(text: $viewModel.username, placeholder: "사용자 이름")
                .focused($focusedField, equals: .username)

            
            Text("3~20자 영문, 숫자")
                .font(._caption)
                .foregroundColor(viewModel.isUsernameInvalid ? .red.opacity(0.7) : .gray50)
            
            SecureField("",text: $viewModel.password,prompt: Text("비밀번호").foregroundColor(.gray50))
                .focused($focusedField, equals: .password)
                .foregroundColor(.gray90)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.gray10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue10, lineWidth: 1)
                )
            
            Text("8자 이상")
                .font(._caption)
                .foregroundColor(viewModel.isPasswordInvalid ? .red.opacity(0.7) : .gray50)
            
            CustomButton(
                action: viewModel.signUp,
                isLoading: viewModel.isLoading,
                text: "계정 생성하기",
                isDisabled: viewModel.isSignUpButtonDisabled
            )
            .padding(.top,32)
            
            Spacer()
            
            Button(action:{
                withAnimation (.fastEaseOut) {
                    viewModel.isSignUp = false
                }
            }){
                Text("로그인으로 돌아가기")
                    .font(._body4)
                    .foregroundStyle(.gray50)
                    .overlay(Rectangle()
                        .fill(.gray30)
                        .frame(height: 1)
                        .offset(y: 2),alignment: .bottom)
            }
            .frame(maxWidth: .infinity,alignment: .center)
            .padding(.top,8)
            .padding(.bottom,32)
        }
    }
    
    private var googleButton: some View {
        Button(action: viewModel.startGoogleSignIn) {
            HStack{
                if viewModel.isGoogleLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity,alignment:.center)
                } else {
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height:16)
                    
                    Text("Google로 시작하기")
                        .font(._body2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.gray00)
            .foregroundColor(.gray60)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray60, lineWidth: 1)
            )
        }
    }

    private var appleButton: some View {
        VStack{
            if viewModel.isAppleLoading {
                ProgressView()
                    .frame(maxWidth: .infinity,alignment:.center)
            } else {
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            viewModel.performAppleLogin(authResults)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                )
            }
        }
        .frame(height: 50)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray60, lineWidth: 1)
        )
    }
}

#if DEBUG
#Preview{
    OnboardingView()
        .environmentObject(AppState.shared)
}
#endif
