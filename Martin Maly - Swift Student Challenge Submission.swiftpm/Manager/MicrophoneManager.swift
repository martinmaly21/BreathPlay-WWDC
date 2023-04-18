import SwiftUI


import AVFoundation
import Accelerate

//This code is heavily based on sample project: https://developer.apple.com/documentation/accelerate/visualizing_sound_as_an_audio_spectrogram
class MicrophoneManager: NSObject, ObservableObject {
    @Published var microphoneReading: Float?
    
    //MARK: - Initialization
    let captureSession = AVCaptureSession()
    let audioOutput = AVCaptureAudioDataOutput()
    
    //MARK: - Queues & Semaphores
    let captureQueue = DispatchQueue(
        label: "captureQueue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    let sessionQueue = DispatchQueue(
        label: "sessionQueue",
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    let dispatchSemaphore = DispatchSemaphore(value: 1)
    
    //MARK: - 🤷🏻‍♂️
    let forwardDCT = vDSP.DCT(
        count: Constants.AudioProcessing.sampleCount.rawValue,
        transformType: .II
    )!
    
    let hanningWindow = vDSP.window(
        ofType: Float.self,
        usingSequence: .hanningDenormalized,
        count: Constants.AudioProcessing.sampleCount.rawValue,
        isHalfWindow: false
    )
    
    //MARK: - Arrays storing audio data
    private var microphoneFrequencyReadings = [Float]()
    private var rawAudioData = [Int16]()
    private var timeDomainBuffer = [Float](
        repeating: 0,
        count: Constants.AudioProcessing.sampleCount.rawValue
    )
    private var frequencyDomainBuffer = [Float](
        repeating: 0,
        count: Constants.AudioProcessing.sampleCount.rawValue
    )
    
    //MARK: - Initialization
    override init() {
        super.init()
        configureCaptureSession()
        audioOutput.setSampleBufferDelegate(
            self,
            queue: captureQueue
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuring and running capture session
    private func configureCaptureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(
                for: .audio,
                completionHandler: { granted in
                    if !granted {
                        fatalError("App requires microphone access.")
                    } else {
                        self.configureCaptureSession()
                        self.sessionQueue.resume()
                    }
                }
            )
            return
        default:
            fatalError("App requires microphone access.")
        }
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        } else {
            fatalError("Can't add `audioOutput`.")
        }
        
        guard let microphone = AVCaptureDevice.default(
            .builtInMicrophone,
            for: .audio,
            position: .unspecified
        ),
              let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create microphone.")
        }
        
        if captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        }
        
        captureSession.commitConfiguration()
    }
    
    public func startRunning() {
        sessionQueue.async {
            guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
                fatalError("Not authorized for microphone use")
            }
            self.captureSession.startRunning()
        }
    }
}

extension MicrophoneManager: AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var audioBufferList = AudioBufferList()
        var blockBuffer: CMBlockBuffer?
        
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout.stride(ofValue: audioBufferList),
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        
        guard let data = audioBufferList.mBuffers.mData else {
            return
        }
        
        if self.rawAudioData.count < Constants.AudioProcessing.sampleCount.rawValue * 2 {
            let actualSampleCount = CMSampleBufferGetNumSamples(sampleBuffer)
            let ptr = data.bindMemory(to: Int16.self, capacity: actualSampleCount)
            let buf = UnsafeBufferPointer(start: ptr, count: actualSampleCount)
            rawAudioData.append(contentsOf: Array(buf))
        }
        
        while self.rawAudioData.count >= Constants.AudioProcessing.sampleCount.rawValue {
            let dataToProcess = Array(self.rawAudioData[0 ..< Constants.AudioProcessing.sampleCount.rawValue])
            self.rawAudioData.removeFirst(Constants.AudioProcessing.hopCount.rawValue)
            self.processData(values: dataToProcess)
        }
    }
    
    private func processData(values: [Int16]) {
        dispatchSemaphore.wait()
        
        //math and pointer stuff
        vDSP.convertElements(
            of: values,
            to: &timeDomainBuffer
        )
        vDSP.multiply(
            timeDomainBuffer,
            hanningWindow,
            result: &timeDomainBuffer
        )
        forwardDCT.transform(
            timeDomainBuffer,
            result: &frequencyDomainBuffer
        )
        vDSP.absolute(
            frequencyDomainBuffer,
            result: &frequencyDomainBuffer
        )
        vDSP.convert(
            amplitude: frequencyDomainBuffer,
            toDecibels: &frequencyDomainBuffer,
            zeroReference: Float(Constants.AudioProcessing.sampleCount.rawValue)
        )
        
        //MARK: - process frequency values
        
        //First, we strip out the bottom 20 values out of the sepctrogram since those seem to always occur
        let numberOfValuesToReplace = 35
        frequencyDomainBuffer.replaceSubrange(0..<numberOfValuesToReplace, with: repeatElement(0, count: numberOfValuesToReplace))
        
        //This is code to set freqency value to MAX if over a certain threshold
        /*
         for (index, frequency) in frequencyDomainBuffer.enumerated() {
         if frequency > 10 {
         frequencyDomainBuffer[index] = 255
         }
         }
         */
        
        //Add all frequency values together
        let sumArray = frequencyDomainBuffer.reduce(0, +)
        
        //average out the past few readings
        let microphoneReading  = averagePastMicrophoneReadings(
            with: sumArray,
            with: &microphoneFrequencyReadings,
            maxElements: 10
        )
        
        self.microphoneReading = microphoneReading
        
        dispatchSemaphore.signal()
    }
    
    
    //average out the last few readings to prevent outliers from drastically fucking anything up
    private func averagePastMicrophoneReadings(
        with newValue: Float,
        with readings: inout [Float],
        maxElements: Int = 10
    ) -> Float {
        if readings.count >= maxElements {
            _ = readings.removeFirst()
        }
        readings.append(newValue)
        
        let sumOfAllReadings = readings.reduce(0, +)
        let numberOfReadings = Float(readings.count)
        
        let averageReading = sumOfAllReadings / numberOfReadings
        
        return averageReading
    }
}
