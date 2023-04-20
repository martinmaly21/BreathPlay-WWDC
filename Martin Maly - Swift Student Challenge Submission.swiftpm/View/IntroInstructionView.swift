import SwiftUI
import AVKit
import Charts

struct IntroInstructionView: View {
    @EnvironmentObject var microphoneManager: MicrophoneManager
    
    @Binding var currentView: AppContainerView.CurrentView
    @State private var edge: Edge = .trailing
    @State private var titlePrompts: [String] = [
        "Make sure you are seated in a very quiet room.",
        "Please remove any headphones if wearing them.",
        "The only thing you should hear is your breath.",
        "Focus on it.",
        "In this practice, you will be breathing in and out through your mouth.",
        "It should sound something like this",
        "Your turn!"
    ]
    @State private var currentPromptIndex: Int = 0
    @State private var titleText: String = "Make sure you are seated in a very quiet room."
    @State private var titleOpacity: Double = 0
    @State private var continueButtonOpacity: Double = 0
    
    @State private var player = AVPlayer()
    
    var body: some View {
        VStack(spacing: 40) { 
            Text(titleText)
                .font(.system(.largeTitle, design: .monospaced))
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
                .opacity(1)
            
            if currentPromptIndex == 5 {
                VideoPlayer(player: player)
                    .frame(width: 444)
                    .frame(height: 450)
                    .disabled(true)
                    .animation(.default)
            } else if currentPromptIndex == 6 {
                VStack {
                    let breathingData = microphoneManager.breathingData.suffix(200)
                    
                    //get last 200 readings
                    
                    if breathingData.count == 200 {
                        Chart {
                            ForEach(breathingData, id: \.date) { item in
                                LineMark(
                                    x: .value("Time", item.date),
                                    y: .value("Breath intensity", item.value)
                                )
                            }
                        }
                        .chartYScale(domain: 0...900)
                        .frame(height: 300)
                    } else {
                        ZStack {
                            Text("Breath data loading...")
                            .font(.system(size: 20, design: .monospaced))
                            .foregroundColor(.gray)
                        }
                        .frame(height: 300)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                             .fill(Color.accentColor.opacity(0.1))
                        
                        if let breathingType = microphoneManager.breathingType {
                            switch breathingType {
                            case .inhale:
                                Text("INHALING")
                                    .font(.system(size: 30, design: .monospaced))
                                    .foregroundColor(.accentColor)
                            case .exhale:
                                Text("EXHALING")
                                    .font(.system(size: 30, design: .monospaced))
                                    .foregroundColor(.accentColor)
                            }
                        } else {
                            Text("NOT BREATHING")
                                .font(.system(size: 30, design: .monospaced))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding()
                    
                    Text("Hint: If not detecting reliably, try turning your input volume all the way up in System Settings")
                        .foregroundColor(.gray)
                        .font(.system(size: 15, design: .monospaced))
                }
                .padding()
            }
            
            Button("Next") {
                guard continueButtonOpacity != 0.3 else { return }
                
                withAnimation(.easeOut(duration: 0.1)) {
                    self.titleOpacity = 0
                    self.continueButtonOpacity = 0.3
                    self.currentPromptIndex += 1
                    titleText = " "
                }
            }
            .buttonStyle(.bordered)
            .font(.system(.body, design: .monospaced))
            .controlSize(.large)
            .tint(.accentColor)
            .opacity(continueButtonOpacity)
            .animation(.default)
        }
        .onAppear {
            if player.currentItem == nil {
                let item = AVPlayerItem(url:  Bundle.main.url(forResource: "RPReplay_Final1681959553", withExtension: "mov")!)
                player.replaceCurrentItem(with: item)
            }
            edge = .leading
            
            withAnimation(.easeIn(duration: 1)) {
                self.continueButtonOpacity = 1
            }
        }
        .onChange(of: currentPromptIndex) { newValue in
            if titlePrompts.count == newValue - 1 {
                currentView = .typesOfBreathView
                return
            }
            
            if currentPromptIndex == 5 {
                player.play()
            }
            
            titleOpacity = 1
            
            titlePrompts[newValue].enumerated().forEach { index, character in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0) {
                    titleText += String(character)
                    
                    if index == titlePrompts[newValue].count - 1 {
                        withAnimation(.linear(duration: 0.5)) {
                            self.continueButtonOpacity = 1
                        }
                    }
                }
                
            }
        }
        .transition(.move(edge: edge))
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
}
