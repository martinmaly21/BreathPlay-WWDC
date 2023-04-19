import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    var body: some View {
        VStack {
            BreathPlayGameView()
            
            if let breathingType = MicrophoneManager.shared.breathingType {
                switch breathingType {
                case .inhale:
                    Text ("Inhale")
                case .exhale:
                     Text ("Exhale")
                }
                
            }
            
        }
    }
}
