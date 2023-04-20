import SwiftUI


struct BreathPlayGameContainerView: View {
    @State private var score: CGFloat = 0
    @State private var userHittingBadness = false
    @State private var currentBreathBoxPositionZPosition: Float = 0
    @State private var totalZTrackLength: Float = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BreathPlayGameView(
                score: $score, 
                userHittingBadness: $userHittingBadness, 
                currentBreathBoxPositionZPosition: $currentBreathBoxPositionZPosition
            )
            
            ZStack {
                VStack(spacing: 10) {
                    if currentBreathBoxPositionZPosition > -700 {
                        Text("Inhale/Exhale to change sides. Try it out!")
                            .font(.system(size: 30, design: .monospaced))
                            .foregroundColor(.accentColor)
                    } else if  currentBreathBoxPositionZPosition > -900 {
                        Text("Now get ready!")
                            .font(.system(size: 30, design: .monospaced))
                            .foregroundColor(.accentColor)
                    } else if  currentBreathBoxPositionZPosition > -1000 {
                        Text("Go!")
                            .font(.system(size: 30, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                .padding()
                
                 
            }.frame(height: 50)
            .padding()
            .background(Color.white)
            .padding()
            .opacity(currentBreathBoxPositionZPosition > -1000 ? 1 : 0)
           
        }
        .overlay(ScoreView(score: $score, userHittingBadness: $userHittingBadness), alignment: .topLeading)
        .overlay(DistanceView(currentBreathBoxPositionZPosition: $currentBreathBoxPositionZPosition), alignment: .topTrailing)
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

struct DistanceView: View {
    @Binding var currentBreathBoxPositionZPosition: Float
    
    var body: some View {
        
        ZStack {
            Text(String(format: "Progress: %.0f%%", abs(currentBreathBoxPositionZPosition) / abs(totalZTrackLength) * 100))
                .font(.system(size: 30, design: .monospaced))
                .foregroundColor(.accentColor)
                .padding()
        }
        .background(Color.white)
    }
}
