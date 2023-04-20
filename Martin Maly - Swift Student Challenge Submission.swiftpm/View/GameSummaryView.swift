import SwiftUI

struct GameSummaryView: View {
    @State private var edge: Edge = .trailing
    
    var body: some View {
        VStack {
            
            VStack(spacing: 40) {
                Text("The benefits of a regular breathing practice are immense")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
                
                
                Text("Thanks for breathing")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
                Text("Final score: \(globalScore)")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }
    }
}
