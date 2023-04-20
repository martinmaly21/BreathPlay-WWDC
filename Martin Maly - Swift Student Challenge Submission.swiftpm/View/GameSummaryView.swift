import SwiftUI

struct GameSummaryView: View {
    @State private var edge: Edge = .trailing
    
    var body: some View {
        Text("Testing")
            .onAppear {
                edge = .leading
            }
            .transition(.move(edge: edge))
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
    }
}
