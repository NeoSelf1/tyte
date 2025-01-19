# TyTE (Track your Time Effectively)
일일 할 일을 관리하고 메쉬 그라디언트 시각화를 통해 생산성을 모니터링하는 SwiftUI 앱입니다.

## 주요 기능
- 🎯 스마트 할 일 관리: AI 기반 작업 분석 및 자동 난이도 평가
- 📊 일일 통계: 생산성 점수 및 워라벨 지표
- 🎨 태그 시스템: 컬러 코딩된 태그로 작업 구성
- 👥 소셜 기능: 친구와 생산성 데이터 공유
- 🔄 위젯 지원: iOS 위젯을 통한 빠른 접근
- 🌗 다크 모드: 자연스러운 테마 전환

## 특별 기능
- 🌈 메쉬 그라디언트 시각화: 생산성 데이터의 시각적 표현
- 📱 실시간 오프라인 지원: 데이터 동기화 시스템
- 🤖 스마트 작업 생성: 자연어 처리를 통한 작업 상세 정보 파악

## 아키텍처
Clean Architecture 원칙과 MVVM 패턴을 따릅니다:
![Group 26](https://github.com/user-attachments/assets/38ec6f91-98e0-4fa3-a3cb-151bd29d66b3)
* 실제 폴더 구조가 아닌 Xcode 그룹 사용으로 프로젝트 구성을 관리합니다.

## 뷰 구조
![Group 25](https://github.com/user-attachments/assets/fbcb3da3-4c01-4360-a82c-435b76decbff)


## Code Convention
- 환경변수 및 환경객체가 의존성에 포함되어있을 경우, 최상단에 배치합니다.
```swift
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState // 최상단에 배치
    
    @StateObject private var viewModel = OnboardingViewModel()
    
    @FocusState private var focusedField: Field?
    @State private var shakeOffset: CGFloat = 0
```

- didSet 옵저버 사용을 지양하고, 내부 메서드를 통해 상태변수 변경과 후처리를 구현합니다.
```swift
// 지양
@Published var currentDate: Date = Date().koreanDate {
 didSet { await fetchData(.monthlyStats(currentDate.apiFormat)) }
}

// 지향
@Published var currentDate: Date = Date().koreanDate
func selectFriend(_ friend: User) {
  currentDate = Date().koreanDate
  ... 
}
```

- List나 ScrollView가 포함된 View와 바인딩된 ViewModel에서는 handleRefresh 메서드를 반드시 구현해 refreshable 뷰 수정자와 연결해줍니다.
```swift
func handleRefresh(){
    Task {
        await fetchTags()
    }
}
```

- 값을 반환하는 메서드에는 return 문이 붎요하더라도 명시하여 가독성을 높힙니다.
```swift
func toggleTodo(_ id: String) async throws -> TodoResponse {
    return try await networkAPI.request(.toggleTodo(id), method: .patch, parameters: nil)
}
```

- import 문 정렬순서는 알파벳순으로 합니다.
```swift
import Combine
import Foundation
import WidgetKit
```

- ``MARK: -`` 상하단에 개행을 1씩 추가해줍니다.
```swift
}

// MARK: - 컴포넌트 변수

extension DetailSection {
```

- 네트워크 연결상태에 따른 로직분리 처리는 Repository에서 진행합니다.
```swift
func get(in date: String) async throws -> [Todo] {
    if NetworkManager.shared.isConnected {
        ...
    } else {
        ...
    }
}
```

## Naming Convention
- 뷰구성의 컴포넌트 역할을 하는 뷰 구조체 이름의 후미에는 Section을 기입합니다.
ex. ``CalendarSection``, ``DetailSection``
- 2개이상의 연속된 요소에 사용되는 컴포넌트 이름의 후미에는 Item을 기입합니다.
ex. ``DayItem``, ``TodoItem``
- 기존 객체를 상속하여 사용하는 컴포넌트 이름의 후미에는 Cell을 기입합니다.
ex. ``MeshGradientCell``

