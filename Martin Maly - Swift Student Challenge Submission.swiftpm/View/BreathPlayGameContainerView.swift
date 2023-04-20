import SwiftUI


struct BreathPlayGameContainerView: View {
    @State private var score: CGFloat = 0
    @State private var userHittingBadness = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BreathPlayGameView(score: $score, userHittingBadness: $userHittingBadness)
            
            ZStack {
                 Text("Inhale/Exhale to change sides")
                    .font(.system(size: 30, design: .monospaced))
                    .foregroundColor(.accentColor)
            }.frame(height: 50)
            .background(Color.white)
           
        }
        .overlay(ScoreView(score: $score, userHittingBadness: $userHittingBadness), alignment: .topLeading)
    }
}

struct ScoreView: View {
    @Binding var score: CGFloat
    @Binding var userHittingBadness: Bool
    
    var body: some View {
        ZStack {
            Text("Score: \(Int(score))")
                .font(.system(size: 30, design: .monospaced))
                .foregroundColor( userHittingBadness ? .red : .accentColor)
                .padding()
        }
        .background(Color.white)
    }
}
