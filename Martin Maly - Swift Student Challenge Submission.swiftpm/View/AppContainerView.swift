import SwiftUI

struct AppContainerView: View {
    enum CurrentView {
        case entryView
        case benefitsView
        case introInstructionView
        case gameView
        case summaryView
    }
    
    @EnvironmentObject var microphoneManager: MicrophoneManager
    @State var previousView: CurrentView?
    @State var currentView: CurrentView = .entryView {
        willSet {
            previousView = currentView
        }
    }
    
    @State private var score: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            switch currentView {
            case .entryView:
                EntryView(currentView: $currentView)
                    .transition(.move(edge: .leading))
            case .benefitsView:
                BenefitsView(currentView: $currentView)
            case .introInstructionView:
                IntroInstructionView(currentView: $currentView)
            case .gameView:
                BreathPlayGameContainerView(currentView: $currentView, score: $score)
            case .summaryView:
                GameSummaryView(score: score)
            }
        }
    }
}

