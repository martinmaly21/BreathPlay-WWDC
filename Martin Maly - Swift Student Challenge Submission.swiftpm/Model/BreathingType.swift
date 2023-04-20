import Foundation

enum BreathingType: Hashable {
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
