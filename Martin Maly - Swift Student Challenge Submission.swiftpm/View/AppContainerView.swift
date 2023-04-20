import SwiftUI

struct AppContainerView: View {
    enum CurrentView {
        case entryView
        case benefitsView
        case introInstructionView
        case typesOfBreathView
    }
    
    @EnvironmentObject var microphoneManager: MicrophoneManager
    @State var previousView: CurrentView?
    @State var currentView: CurrentView = .introInstructionView {
        willSet {
            previousView = currentView
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            switch currentView {
            case .entryView:
                EntryView(currentView: $currentView)
                    .transition(.move(edge: .leading))
            case .benefitsView:
                let _ = print(previousView)
                BenefitsView(currentView: $currentView)
            case .introInstructionView:
                IntroInstructionView(currentView: $currentView)
            case .typesOfBreathView:
                TypesOfBreathView(currentView: $currentView)
            }
        }
    }
}

