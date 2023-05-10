import SwiftUI

struct GameSummaryView: View {
    let score: CGFloat
    
    var body: some View {
        VStack {
            
            VStack(spacing: 40) {
                Text("The benefits of a regular breathing practice are immense.")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.center)
                
                Text("Thanks for breathing!")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
                Text("Final score: \(Int(score))")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }
    }
}
