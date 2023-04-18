import SwiftUI

//This can be changed by user depending on the room they're in
var breathAudioSensitivityValue = 200

enum Constants {
    enum AudioProcessing: Int {
        case sampleCount = 1024
        case bufferCount = 768
        case hopCount = 512
    }
}
