import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    var body: some View {
        VStack {
            BreathPlayGameView()
        }
    }
}
