import SwiftUI

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
