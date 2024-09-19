//
//  CustomTabBar.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var sharedVM = SharedTodoViewModel()
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var listVM = ListViewModel()
    
    @State private var selectedTab = 0
    @State private var todoInput = ""
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                NavigationStack {
                    TabView(selection: $selectedTab) {
                        HomeView(viewModel: homeVM)
                            .tabItem {
                                TabBarItem(icon: "house.fill", text: "홈")
                            }
                            .tag(0)
                        
                        ListView(viewModel: listVM, sharedVM: sharedVM)
                            .tabItem {
                                TabBarItem(icon: "calendar",  text: "일정 관리")
                            }
                            .tag(1)
                        
                        MyPageView()
                            .tabItem {
                                TabBarItem(icon: "person.fill", text: "MY")
                            }
                            .tag(2)
                    }
                    .onAppear {
                        homeVM.setupBindings(sharedVM: sharedVM)
                        listVM.setupBindings(sharedVM: sharedVM)
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TextField("",
                          text: $todoInput,
                          prompt: Text("Todo를 자연스럽게 입력해주세요...")
                    .foregroundColor(.gray50)
                )
                .focused($isInputFocused)
                .onSubmit {
                    sharedVM.addTodo(todoInput)
                    todoInput = ""
                }
                .foregroundColor(.gray90)
                .padding()
                .background(.gray00)
                .cornerRadius(16)
                .shadow(color: .gray90.opacity(0.05), radius: 10)
                .padding(.horizontal)
                .padding(.bottom, 64)  // 하단 여백 추가
            }
        }
        .simultaneousGesture(
            isInputFocused ? TapGesture()
                .onEnded { _ in
                    if isInputFocused {
                        isInputFocused = false
                    }
                } : nil
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack (spacing:2) {
            Image(systemName: icon)
                .font(._caption)
            Text(text)
                .font(._caption)
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
}
