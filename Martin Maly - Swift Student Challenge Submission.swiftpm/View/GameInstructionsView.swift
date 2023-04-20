import SwiftUI


struct GameInstructionsView: View {
    @Binding var currentView: AppContainerView.CurrentView
    @State private var edge: Edge = .trailing
    
    var body: some View {
        
        VStack {
            //TODO: Instructions
            
            
            Button("Let's play!") {
                withAnimation(.easeOut(duration: 1)) {
                    self.currentView = .gameView
                }
            }
            .buttonStyle(.bordered)
            .font(.system(.body, design: .monospaced))
            .controlSize(.large)
            .tint(.accentColor)
            .opacity(1)
        }
    }
}
