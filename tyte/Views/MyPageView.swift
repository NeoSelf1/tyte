//
//  MyPageView.swift
//  tyte
//
//  Created by 김 형석 on 9/14/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var viewModel: MyPageViewModel = MyPageViewModel()
    @State private var bottomSheetPosition: PresentationDetent = .height(720)
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(isDarkMode ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            VStack{
                VStack (spacing:0){
                    HStack (alignment: .center){
                        Text("내 정보")
                            .font(._headline2)
                            .foregroundColor(.gray90)
                        
                        Spacer()
                            .frame(width:120)
                        
                        ViewSelector(viewModel: viewModel)
                    }
                    .frame(height:56)
                    .padding(.horizontal)
                    
                    if (viewModel.currentTab == 0){
                        VStack(spacing: 12) {
                            HStack{
                                Text("기록이 있는 날짜를 선택하면 상세분석결과를 확인할 수 있어요")
                                    .font(._body3)
                                    .foregroundColor(.gray50)
                                Spacer()
                            }
                            .padding()
                            .background(.gray10)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            CalenderView(viewModel: viewModel)
                        }
                        .frame(maxHeight: 450)
                    } else {
                        GraphView(viewModel: viewModel)
                            .frame(maxHeight: 360)
                    }
                }.background(.gray00)
                
                Toggle(isOn: $isDarkMode) {
                    Text("다크모드")
                        .font(._body1)
                        .foregroundColor(.gray90)
                }
                .padding()
                .background(Color.gray10)
                .cornerRadius(8)
                .onChange(of: isDarkMode) { _,newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnimating = true
                        setAppearance(isDarkMode: newValue)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isAnimating = false
                        }
                    }
                }
                
                Button(action: {
                    authVM.logout()
                }) {
                    Text("로그아웃")
                        .font(._body1)
                        .foregroundColor(.blue30)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue10)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .background(.gray10)
            .sheet(isPresented: $viewModel.isDetailViewPresented) {
                MultiLayerBottomSheet(viewModel: viewModel, bottomSheetPosition: $bottomSheetPosition)
                    .presentationDetents([.height(720), .large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}
private func setAppearance(isDarkMode: Bool) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
