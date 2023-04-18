import SwiftUI

@main
struct BreathPlayApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    let microphoneManager = MicrophoneManager()
    
    var body: some Scene {
        WindowGroup {
            AppContainerView()
                .environmentObject(microphoneManager)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task(priority: .userInitiated) {
                    microphoneManager.startRunning()
                }
            }
        }
    }
}
