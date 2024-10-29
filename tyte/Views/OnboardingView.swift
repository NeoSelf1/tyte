import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?
    @State private var shakeOffset: CGFloat = 0
    @State private var isToastPresented = false
    
    enum Field: Hashable {
        case email
        case password
        case username
    }
    
    var body: some View {
        ZStack{
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            if isToastPresented, let toast = viewModel.currentToast {
                CustomToast(toastData: toast)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 80)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .animation(.mediumEaseInOut, value: isToastPresented)
            }
            
            VStack(spacing: 8) {
                Thumbnail()
                
                VStack{
                    Text(viewModel.errorText)
                        .font(._body3)
                        .foregroundColor(.red).opacity(0.7)
                        .frame(maxWidth: .infinity,maxHeight: 64,alignment: .bottomLeading)
                    
                    if !viewModel.isSignUp {
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
                            .onAppear {
                                focusedField = Field.password
                            }
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
                        
                        orDivider.padding(.vertical,12)
                        
                        googleButton(viewModel: viewModel)
                        
                        appleButton(viewModel: viewModel)
                        
                        Button(action:{
                            withAnimation(.mediumEaseInOut){
                                withAnimation(.fastEaseInOut) {
                                    appState.isGuestMode = true
                                }
                            }
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
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            CustomTextField(text: $viewModel.username, placeholder: "사용자 이름")
                                .focused($focusedField, equals: .username)
                                .padding(.top,64)
                            
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
                            ).padding(.top,4)
                            
                            Button(action:{
                                withAnimation(.mediumEaseInOut){
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
                        }
                        .onAppear {
                            focusedField = Field.username
                        }
                    }
                }
            }
            .padding(.horizontal)
        }.onAppear{
            viewModel.isSignUp = false
            viewModel.isExistingUser = false
        }
        .onChange(of: viewModel.currentToast?.text) { _, newValue in
            if newValue != nil {
                withAnimation {
                    isToastPresented = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isToastPresented = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.currentToast = nil
                    }
                }
            }
        }
    }
}

struct Thumbnail: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack{
            Image("logo-transparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .padding(.bottom,8)
            
            Image(colorScheme == .dark ? "logo-dark" : "logo-light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:24)
            
            VStack(spacing:4){
                Text("일상의 균형과 생산성을 높이는 스마트한")
                    .font(._title)
                    .foregroundStyle(.gray60)
                Text("Todo 어플리케이션")
                    .font(._title)
                    .foregroundStyle(.gray60)
            }.padding(.top,8)
        }
    }
}

private var orDivider: some View {
    HStack {
        VStack { Divider() }.padding(.horizontal, 20)
        Text("또는")
            .foregroundColor(.gray60)
            .font(._caption)
        VStack { Divider() }.padding(.horizontal, 20)
    }
}
    
private func googleButton(viewModel:AuthViewModel) -> some View {
    Button(action: viewModel.startGoogleSignIn) {
        HStack{
            Image("google")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:16)
            
            Text("Google로 시작하기")
                .font(._body2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.gray00)
        .foregroundColor(.gray60)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray60, lineWidth: 1)
        )
    }
}

private func appleButton(viewModel: AuthViewModel) -> some View {
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
    .frame(height: 50)
    .cornerRadius(10)
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray60, lineWidth: 1)
    )
}


#Preview{
    OnboardingView()
}
