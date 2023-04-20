import SwiftUI

struct AppContainerView: View {
    enum CurrentView {
        case entryView
        case benefitsView
    }
    
    @EnvironmentObject var microphoneManager: MicrophoneManager
    @State var currentView: CurrentView = .entryView
    
    var body: some View {
        ZStack(alignment: .center) {
            switch currentView {
            case .entryView:
                EntryView(currentView: $currentView)
                    .transition(.move(edge: .leading))
            case .benefitsView:
                BenefitsView(currentView: $currentView)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

// The benefits of a regular breathing practice are immense. Improved mental clarity, reduced anxiety, and increased mood to name a few.
// But, like anything, it can be tough to establish a regular practice.
// So today we're going to learn how to do just that. 
// And have some fun, too.

// First, make sure you are seated in a quiet room. The only thing you should hear is your breath.
// Breath in and out through your mouth, and your breaths should sound a little like this. 
//IN:
//(MEMOJI)
//OUT:
//(MEMOJI)

//The louder and more defined the better!

//Your turn.

// Let's adjust this slider to get suited to
// We reccomend using airpods pro for the sound, but to use your computer speakers for the microphone.


//Introduce the game? Or talk about the four breath types
    
