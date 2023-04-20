import SwiftUI


struct EntryView: View {
    @Binding var currentView: AppContainerView.CurrentView
    @State private var title: String = ""
    @State private var subtitle: String = " "
    @State private var hasPerformedDeleteAnimation = false
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 40) {
                Text(title)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 80, design: .monospaced))
                
                Text(subtitle)
                    .font(.system(.largeTitle, design: .monospaced))
                    .opacity(subtitle.isEmpty ? 0 : 1)
                    .padding(.bottom, 40)
                
                
                Button("Continue") {
                    withAnimation(.easeOut(duration: 1)) {
                        self.currentView = .benefitsView
                    }
                }
                .buttonStyle(.bordered)
                .font(.system(.body, design: .monospaced))
                .controlSize(.large)
                .tint(.accentColor)
                .opacity(buttonOpacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .overlay(FooterView(), alignment: .bottomLeading)
        .padding()
        .onChange(of: title) { newValue in
            if newValue == "Breathwork" {
                withAnimation(.linear(duration: 0.01)) {
                    "work".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.15) {
                            _ = title.removeLast()
                            hasPerformedDeleteAnimation = true
                        }
                    }
                }
            } else if newValue == "Breath" && hasPerformedDeleteAnimation {
                withAnimation(.linear(duration: 0.01)) {
                    "Play :)".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.15) {
                            title += String(character)
                        }
                    }
                }
            } else if newValue == "BreathPlay :)" {
                withAnimation(.linear(duration: 0.01)) {
                    "Taking the 'work' out of breathwork.".enumerated().forEach { index, character in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 +  Double(index) * 0.05) {
                            subtitle += String(character)
                            
                            if index == "Taking the 'work' out of breathwork.".count - 1 {
                                withAnimation(.linear(duration: 1)) {
                                    buttonOpacity = 1
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.01)) {
                "Breathwork".enumerated().forEach { index, character in
                    DispatchQueue.main.asyncAfter(deadline: .now() +  Double(index) * 0.15) {
                        title += String(character)
                    }
                }
            }
        }
    }
}
