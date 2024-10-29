//
//  SettingsView.swift
//  tyte
//
//  Created by 김 형석 on 10/1/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    @AppStorage("isDarkMode") private var isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    
    var body: some View {
        ZStack{
            Color(isDarkMode ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Toggle(isOn: $isDarkMode) {
                    Text("다크모드")
                        .font(._body2)
                        .foregroundColor(.gray90)
                }
                .padding()
                .tint(.blue30)
                .background(Color.gray10)
                .cornerRadius(8)
                .onChange(of: isDarkMode) { _,newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        setAppearance(isDarkMode: newValue)
                    }
                }
                
                Divider()
                    .padding(.vertical,12)
                
                VStack(spacing:12){
                    Button(action: {
                        withAnimation(.mediumEaseInOut){
                            showLogoutAlert = true
                        }
                    }) {
                        Text("로그아웃")
                            .font(._body1)
                            .foregroundColor(.blue30)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue10)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.mediumEaseInOut){
                            showDeleteAccountAlert = true
                        }
                    }) {
                        Text("계정삭제")
                            .font(._body1)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray10)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(.gray00)
            
            
            if showLogoutAlert {
                CustomPopupTwoBtn(
                    isShowing: $showLogoutAlert,
                    title: "로그아웃",
                    message: "정말로 로그아웃 하시겠습니까?",
                    primaryButtonTitle: "로그아웃",
                    secondaryButtonTitle: "취소",
                    primaryAction: {
                        viewModel.logout()
                    },
                    secondaryAction: {}
                )
            }
            
            if showDeleteAccountAlert {
                CustomPopupTwoBtn(
                    isShowing: $showDeleteAccountAlert,
                    title: "계정삭제",
                    message: "정말로 계정을 삭제하시겠습니까?",
                    primaryButtonTitle: "계정삭제",
                    secondaryButtonTitle: "취소",
                    primaryAction: {
                        viewModel.deleteAccount()
                    },
                    secondaryAction: {}
                )
            }
        }
        .navigationBarTitle("설정", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { dismiss() }){
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray90)
            }
        )
    }
}

private func setAppearance(isDarkMode: Bool) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}

#Preview{
    SettingsView()
}
