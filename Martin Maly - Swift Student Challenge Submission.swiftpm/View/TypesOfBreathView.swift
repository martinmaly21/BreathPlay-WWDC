import SwiftUI


struct TypesOfBreathView: View {
    @Binding var currentView: AppContainerView.CurrentView
    @State private var edge: Edge = .trailing
    
    var body: some View {
        Text("TYPES")
            .onAppear {
                edge = .leading
            }
            .transition(.move(edge: edge))
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
    }
}
