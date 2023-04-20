import SwiftUI

struct AppContainerView: View {
    enum CurrentView {
        case entryView
        case benefitsView
        case introInstructionView
        case gameInstructionsView
        case gameView
        case summaryView
    }
    
    @EnvironmentObject var microphoneManager: MicrophoneManager
    @State var previousView: CurrentView?
    @State var currentView: CurrentView = .gameInstructionsView {
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
            case .gameInstructionsView:
                GameInstructionsView(currentView: $currentView)
            case .gameView:
                BreathPlayGameContainerView()
            case .summaryView:
                GameSummaryView()
            }
        }
    }
}

