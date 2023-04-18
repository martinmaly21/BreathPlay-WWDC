import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    var body: some View {
        VStack {
            Text("Breathwork!")
            
            if let microphoneReading = microphoneManager.microphoneReading {
                Text("Microphone value: \(microphoneReading)!")
            }
        }
    }
}
