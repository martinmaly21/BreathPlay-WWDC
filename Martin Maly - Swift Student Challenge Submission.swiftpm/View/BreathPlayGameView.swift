import SwiftUI
import SceneKit

struct BreathPlayGameView: UIViewRepresentable {
    public let sceneView = SCNView()
    public let breathBoxNode = SCNNode()
    public let focusNode = SCNNode()
    public let selfieStickNode = SCNNode()
    
    class Coordinator: NSObject, SCNSceneRendererDelegate, CAAnimationDelegate {
        let parent: BreathPlayGameView
        var timer = Timer()
        var animationStartedBreathingType: BreathingType?
        var previousBreathingType: BreathingType?
        
        init(_ parent: BreathPlayGameView) {
            self.parent = parent
            super.init()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                if let breathingType = MicrophoneManager.shared.breathingType {
                    let desiredOffset = breathingType == .inhale ? 26 : -26
                    
                    if breathingType != self.previousBreathingType && self.animationStartedBreathingType == nil {
                        self.animationStartedBreathingType = breathingType
                        //animate change
                        let animation = CABasicAnimation(keyPath: "position.x")
                        animation.fillMode = .forwards
                        animation.isRemovedOnCompletion = false
                        animation.fromValue = parent.breathBoxNode.position.x
                        animation.toValue = desiredOffset
                        animation.duration = 0.1
                        animation.delegate = self
                        parent.breathBoxNode.addAnimation(animation, forKey: "position.x")
                    }
                    
                    self.previousBreathingType = breathingType
                }
                
                //move nodes forward
                parent.breathBoxNode.position.z -= 2
                parent.focusNode.position.z -= 2
            })
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            //
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            guard let breathingType = animationStartedBreathingType else {
                fatalError("Could not find animationStartedBreathingType")
            }
            MicrophoneManager.shared.breathingType = breathingType
            
            parent.breathBoxNode.position.x =  breathingType == .inhale ? 26 : -26
            parent.breathBoxNode.removeAnimation(forKey: "position.x")
            
            self.animationStartedBreathingType = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        sceneView.delegate = context.coordinator
        
        let scene = SCNScene()
        
        let focusNodeGeometry = SCNSphere(radius: 0.001)
        focusNode.geometry = focusNodeGeometry
        focusNode.worldPosition = SCNVector3(x: 0, y: 5, z: 0)
        scene.rootNode.addChildNode(focusNode)
        
        let boxGeometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0.5)
        breathBoxNode.geometry = boxGeometry
        breathBoxNode.worldPosition = SCNVector3(x: 0, y: 5, z: 0)
        breathBoxNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        scene.rootNode.addChildNode(breathBoxNode)
        
        selfieStickNode.camera = SCNCamera()
        selfieStickNode.camera?.zFar = 1000
        selfieStickNode.position = SCNVector3(0, 8, 5)
        scene.rootNode.addChildNode(selfieStickNode)
        
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let cameraZoom = 50
        let cameraZPos = cameraZoom / 1 // cameraZoom == 100
        let replicatorConstraint = SCNReplicatorConstraint(target: focusNode)
        replicatorConstraint.positionOffset = SCNVector3(0 ,60, 80)
        replicatorConstraint.replicatesOrientation = false
        
        let lookAtConstraint = SCNLookAtConstraint(target: focusNode)
        lookAtConstraint.influenceFactor = 0.07
        lookAtConstraint.isGimbalLockEnabled = true
        
        selfieStickNode.constraints = [replicatorConstraint, lookAtConstraint]
        lightNode.constraints = [replicatorConstraint, lookAtConstraint]
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let leftPipe = SCNNode()
        leftPipe.geometry = SCNBox(width: 4, height: 2, length: 100000, chamferRadius: 3)
        leftPipe.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        leftPipe.position = SCNVector3(-50, 0.1, 0)
        scene.rootNode.addChildNode(leftPipe)
        
        let rightPipe = SCNNode()
        rightPipe.geometry = SCNBox(width: 4, height: 2, length: 100000, chamferRadius: 3)
        rightPipe.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        rightPipe.position = SCNVector3(50, 0.1, 0)
        scene.rootNode.addChildNode(rightPipe)

        for i in 0..<200 {
            let planeWidth: CGFloat = 150
            let planeHeight: CGFloat = 180
            let planeShape = SCNPlane(width: planeWidth, height: planeHeight)
            let planeShapeNode = SCNNode(geometry: planeShape)
            planeShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            planeShapeNode.geometry?.firstMaterial?.isDoubleSided = true
            planeShapeNode.position = SCNVector3.init(x: 0, y: -0.0001, z: -(Float(planeHeight) / 2) - (Float(i) * Float(planeHeight)))
            planeShapeNode.eulerAngles = SCNVector3(CGFloat.pi * -0.5, 0.0, 0.0)
            
            let crossPathHeight: CGFloat = 60
            let crossPathGeo = SCNPlane(width: planeWidth - 48, height: crossPathHeight)
            let crossPathNode = SCNNode(geometry: crossPathGeo)
            crossPathNode.position = SCNVector3.init(x: 0, y: 90 - (Float(crossPathHeight) / 2), z: 0.1)
            crossPathNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            planeShapeNode.addChildNode(crossPathNode)
            
            let isEven = i % 2 == 0
            
            let goodSideHeight = planeHeight - crossPathHeight
            let goodSideWidth: CGFloat = (85 / 2)
            let goodPlaneShape = SCNPlane(width: goodSideWidth, height: goodSideHeight)
            let goodPlaneShapeNode = SCNNode(geometry: goodPlaneShape)
            goodPlaneShapeNode.position = SCNVector3.init(x: isEven ? -30 : 30, y: -((Float(crossPathHeight) / 2)), z: 0.5)
            goodPlaneShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            planeShapeNode.addChildNode(goodPlaneShapeNode)
            
            let badSideHeight = planeHeight - crossPathHeight
            let badSideWidth: CGFloat = (85 / 2)
            let badPlaneShape = SCNPlane(width: badSideWidth, height: badSideHeight)
            let badPlaneShapeNode = SCNNode(geometry: badPlaneShape)
            badPlaneShapeNode.position = SCNVector3.init(x: isEven ? 30 : -30, y: -((Float(crossPathHeight) / 2)), z: 0.5)
            badPlaneShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            planeShapeNode.addChildNode(badPlaneShapeNode)
            
            
            scene.rootNode.addChildNode(planeShapeNode)
        }
        
        sceneView.rendersContinuously = true
        sceneView.scene = scene
        sceneView.debugOptions = [.showPhysicsShapes]
        
        //for testing
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
