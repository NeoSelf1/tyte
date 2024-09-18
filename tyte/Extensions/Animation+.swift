import SwiftUI

extension Animation {
    struct Duration {
        static let fast: Double = 0.1
        static let medium: Double = 0.2
        static let slow: Double = 0.5
    }
    
    struct Curve {
        static let standard = Animation.easeInOut
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)
    }
    
    static var fastEaseOut: Animation {
        easeOut(duration: Duration.fast)
    }
    
    static var mediumEaseOut: Animation {
        easeOut(duration: Duration.medium)
    }
    
    static var longEaseOut: Animation {
        easeInOut(duration: Duration.slow)
    }
    
    static var fastEaseInOut: Animation {
        easeInOut(duration: Duration.fast)
    }
    
    static var mediumEaseInOut: Animation {
        easeInOut(duration: Duration.medium)
    }
    
    static var fastBouncy: Animation {
        Curve.bouncy.speed(Duration.fast / Duration.medium)
    }
    
    static var mediumBouncy: Animation {
        Curve.bouncy
    }
}
