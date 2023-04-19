import SwiftUI

//This can be changed by user depending on the room they're in
//This value works very well for input gain all the way UP on microphone
var breathAudioSensitivityValue = 91

enum Constants {
    enum AudioProcessing: Int {
        case sampleCount = 1024
        case bufferCount = 768
        case hopCount = 512
    }
    
    enum BitMask: Int {
        case floor = 0b0001
        case box = 0b0010
        
        case greenPath = 0b0100
        case redPath = 0b1000
    }
    
    enum SegmentTypes: Int, CaseIterable {
        case fire = 100
        case air = 200
        case water = 400
        case earth = 800
//        case freeForAll = 0
    }
}
