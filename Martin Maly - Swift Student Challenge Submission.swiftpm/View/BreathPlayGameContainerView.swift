import SwiftUI


struct BreathPlayGameContainerView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            BreathPlayGameView()
            
            ZStack {
                 Text("Inhale/Exhale to change sides")
                    .font(.system(size: 30, design: .monospaced))
                    .foregroundColor(.accentColor)
            }.frame(height: 50)
            .background(Color.white)
           
        }
        .overlay(ScoreView(), alignment: .topLeading)
    }
}

struct ScoreView: View {
    var body: some View {
        ZStack {
            Text("Score: \(4423)")
        }
        .background(Color.white)
    }
}
