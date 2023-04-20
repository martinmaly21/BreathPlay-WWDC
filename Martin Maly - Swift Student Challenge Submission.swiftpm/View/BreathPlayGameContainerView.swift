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
                currentBreathBoxPositionZPosition: $currentBreathBoxPositionZPosition,
                totalZTrackLength: $totalZTrackLength
            )
            
            ZStack {
                VStack(spacing: 10) {
                    if currentBreathBoxPositionZPosition > -1000 {
                        Text("Inhale/Exhale to change sides. Try it out!")
                            .font(.system(size: 30, design: .monospaced))
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
                
                .opacity(1)
                 
            }.frame(height: 50)
            .padding()
            .background(Color.white)
            .padding()
           
        }
        .overlay(ScoreView(score: $score, userHittingBadness: $userHittingBadness), alignment: .topLeading)
        .overlay(DistanceView(currentBreathBoxPositionZPosition: $currentBreathBoxPositionZPosition, totalZTrackLength: $totalZTrackLength), alignment: .topTrailing)
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
    @Binding var totalZTrackLength: Float
    
    var body: some View {
        VStack {
            Text("currentBreathBoxPositionZPosition: \(currentBreathBoxPositionZPosition))")
                .font(.system(size: 30, design: .monospaced))
            Text("totalZTrackLength: \(totalZTrackLength))")
                .font(.system(size: 30, design: .monospaced))
        }
        .background(Color.white)
    }
}
