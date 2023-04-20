import SwiftUI

struct BenefitsView: View {
    @Binding var currentView: AppContainerView.CurrentView
    
    @State private var benefit1: String = " "
    @State private var benefit2: String = " "
    @State private var benefit3: String = " "
    @State private var benefit4: String = " "
    
    @State private var continueButtonOpacity: CGFloat = 0
    
    @State private var edge: Edge = .trailing
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Text("The benefits of a regular breathing practice are immense")
                    .font(.system(.largeTitle, design: .monospaced))
                    .foregroundColor(.accentColor)
                
                Button("Continue") {
                    withAnimation(.easeOut(duration: 1)) {
                        self.currentView = .introInstructionView
                    }
                }
                .buttonStyle(.bordered)
                .font(.system(.body, design: .monospaced))
                .controlSize(.large)
                .tint(.accentColor)
                .opacity(continueButtonOpacity)
            }
            
            
            Text(benefit1)
                .font(.system(size: 30, design: .monospaced))
                .position(x: 300, y: 80)
            Text(benefit2)
                .font(.system(size: 30, design: .monospaced))
                .position(x: 900, y: 280)
            Text(benefit3)
                .font(.system(size: 30, design: .monospaced))
                .position(x: 300, y: 670)
            Text(benefit4)
                .font(.system(size: 30, design: .monospaced))
                .position(x: 800, y: 800)
        }
        .onAppear {
            edge = .leading
        }
        .transition(.move(edge: edge))
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 0.01)) {
                "Improved mental clarity".enumerated().forEach { index, character in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.05) {
                        benefit1 += String(character)
                    }
                }
            }
        }
        .onChange(of: benefit1) { newValue in
            if newValue == " Improved mental clarity" {
                withAnimation(.linear(duration: 0.01)) {
                    "Reduced anxiety".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.05) {
                            benefit2 += String(character)
                        }
                    }
                }
            }
        }
        .onChange(of: benefit2) { newValue in
            if newValue == " Reduced anxiety" {
                withAnimation(.linear(duration: 0.01)) {
                    "Increased mood".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.05) {
                            benefit3 += String(character)
                        }
                    }
                }
            }
        }
        .onChange(of: benefit3) { newValue in
            if newValue == " Increased mood" {
                withAnimation(.linear(duration: 0.01)) {
                    "And many, many more".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.05) {
                            benefit4 += String(character)
                        }
                    }
                }
            }
        }
        .onChange(of: benefit4) { newValue in
            if newValue == " And many, many more" {
                withAnimation(.linear(duration: 1)) {
                    continueButtonOpacity = 1
                }
            }
        }
    }
}
