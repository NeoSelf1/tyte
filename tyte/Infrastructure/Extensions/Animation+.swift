import SwiftUI

/// SwiftUI 애니메이션을 위한 Animation 확장입니다.
///
/// 자주 사용되는 애니메이션 프리셋을 제공합니다:
/// - 다양한 지속 시간 설정
/// - 이징 함수 조합
///
/// ## 사용 예시
/// ```swift
/// // 빠른 애니메이션
/// withAnimation(.fastEaseOut) {
///     isVisible = true
/// }
///
/// // 중간 속도 애니메이션
/// withAnimation(.mediumEaseInOut) {
///     offset = 100
/// }
/// ```
///
/// ## 지속 시간 상수
/// - ``Duration.fast``: 0.1초
/// - ``Duration.medium``: 0.3초
/// - ``Duration.slow``: 1.0초
///
/// - Note: 모든 애니메이션은 적절한 이징을 포함합니다.
extension Animation {
    struct Duration {
        static let fast: Double = 0.1
        static let mediumFast: Double = 0.2
        static let medium: Double = 0.3
        static let slow: Double = 1
    }
    
    static var fastEaseOut: Animation {
        easeOut(duration: Duration.fast)
    }
    
    static var mediumEaseOut: Animation {
        easeOut(duration: Duration.medium)
    }
    
    static var fastEaseInOut: Animation {
        easeInOut(duration: Duration.fast)
    }
    
    static var mediumFastEaseInOut: Animation {
        easeInOut(duration: Duration.mediumFast)
    }
    
    static var mediumEaseInOut: Animation {
        easeInOut(duration: Duration.medium)
    }
    
    static var longEaseInOut: Animation {
        easeInOut(duration: Duration.slow)
    }
}
