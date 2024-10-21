//
//  AppState.swift
//  tyte
//
//  Created by Neoself on 10/19/24.
//
import Foundation

// 앱의 전체 클래스를 도입하여 앱의 전체 상태를 관리
// 로그인 여부, 게스트모드 여부에 따라 접근가능한 화면에 제한두기 위해 ObservableObject 프로토콜 채택하여, SwiftUI 반응형 시스템과 통합.
class AppState: ObservableObject {
    static let shared = AppState() // 전역적으로 접근 가능한 인스턴스 생성. 이는 싱글톤으로 구현되어있는 APIManager에서 appState를 직접 접근하게 하기 위해서임.
    
    @Published var isLoggedIn: Bool = false // Published 래퍼를 통해 상태 변화를 SwiftUI 뷰에 자동반영
    @Published var isGuestMode: Bool = false
    @Published var isLoginRequiredViewPresented: Bool = false
//    @Published var currentPopup: PopupType?
}
