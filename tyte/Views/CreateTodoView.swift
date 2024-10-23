//
//  CreateTodoView.swift
//  tyte
//
//  Created by 김 형석 on 9/19/24.
//

import SwiftUI

struct CreateTodoView: View {
    @ObservedObject var viewModel : HomeViewModel
    
    @State private var todoInput = ""
    @State private var currentExampleIndex = 0
    @State private var isAnimating = false
    @FocusState private var isTodoInputFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    let examples = [
        ("회의 준비하기, 보고서 작성", "쉼표로 구분하면 여러 할 일을 한 번에 추가할 수 있어요."),
        ("중요한 프레젠테이션 준비!", "느낌표를 붙이면 최우선 순위로 설정되어 목록 최상단에 표시됩니다."),
        ("헬스장 가기 30분", "소요시간을 함께 적으면 보다 정확한 생산지수 및 균형지수 계산이 가능해져요."),
        ("어려운 코딩 과제 완료하기", "앱이 자동으로 난이도를 분석하여 1-5 단계로 표시해 드립니다."),
        ("다음주 월요일 팀 미팅", "앱이 자동으로 날짜를 인식하고 정확한 일정에 추가해 드려요.")
    ]
    
    let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer().frame(height:16)
            
            ZStack{
                VStack(alignment: .leading, spacing: 8) {
                    HStack (alignment: .bottom, spacing: 2){
                        Text("\(currentExampleIndex+1).")
                            .font(._subhead1)
                            .foregroundColor(.gray60)
                        
                        Text("\"")
                            .font(._body3)
                            .foregroundColor(.gray90)
                        
                        Text(examples[currentExampleIndex].0)
                            .font(._subhead1)
                            .foregroundColor(.gray90)
                        
                        Text("\"")
                            .font(._body3)
                            .foregroundColor(.gray90)
                        
                        Text(" 라고 입력해보세요")
                            .font(._body3)
                            .foregroundColor(.gray50)
                        
                        Spacer()
                    }
                    
                    Text(examples[currentExampleIndex].1)
                        .font(._body1)
                        .foregroundColor(.gray50)
                }
                .padding(16)
                .frame(maxWidth:.infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(.gray10))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5), value: isAnimating)
                .id(currentExampleIndex)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)))
            }
            
            Spacer()
            
            Text("AI로 Todo 추가하기")
                .font(._body3)
                .foregroundColor(.gray90)
                .padding(.leading,4)
                .frame(maxWidth:.infinity,alignment:.leading)
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.gray50)
                    .frame(height: 56)
                
            } else {
                TextField("",
                          text: $todoInput,
                          prompt: Text("Todo를 자연스럽게 입력해주세요...")
                    .foregroundColor(.gray)
                )
                .foregroundColor(.gray90)
                .submitLabel(.done)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.gray10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue10, lineWidth: 1)
                )
                .focused($isTodoInputFocused)
                .onSubmit {
                    guard !todoInput.isEmpty else { return }
                    viewModel.addTodo(todoInput)
                    todoInput = ""
                }
                .frame(height: 56)
            }
        }
        .padding(16)
        .background(.gray00)
        .onReceive(timer) { _ in
            withAnimation {
                isAnimating = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentExampleIndex = (currentExampleIndex + 1) % examples.count
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .onChange(of: viewModel.isLoading) { _,newValue in
            if !newValue {
                dismiss()
            }
        }
        .onAppear {
            isAnimating = true
            isTodoInputFocused = true
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            CreateTodoView(viewModel:HomeViewModel())
                .frame(height:260) // 높이를 조절하세요. 300은 예시 값입니다.
        }
    }
    
    return PreviewWrapper()
}
