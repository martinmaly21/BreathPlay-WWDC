import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    var body: some View {
        VStack {
            Text("Breathwork!")
            
            if let breathingType = microphoneManager.breathingType {
                switch breathingType {
                case .inhale:
                    Text("Inhale")
                case .exhale: 
                    Text("Exhale")
                }
            }
        }
    }
}
