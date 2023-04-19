import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    var body: some View {
        VStack {
            BreathPlayGameView(breathingType: $microphoneManager.breathingType)
                .frame(width: 500, height: 500)
            
            if let breathingType = microphoneManager.breathingType {
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
