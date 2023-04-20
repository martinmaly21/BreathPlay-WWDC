import SwiftUI

struct BenefitsView: View {
    @Binding var currentView: AppContainerView.CurrentView
    
    var body: some View {
        Text("Benefits")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
