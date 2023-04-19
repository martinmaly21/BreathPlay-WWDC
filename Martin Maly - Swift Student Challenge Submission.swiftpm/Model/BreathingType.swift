import Foundation

enum BreathingType {
    case inhale
    case exhale
    
    var next: BreathingType {
        switch self {
        case .inhale:
            return .exhale
        case .exhale:
            return .inhale
        }
    }
}
