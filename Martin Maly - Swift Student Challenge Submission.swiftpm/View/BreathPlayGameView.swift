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
            let node = parent.breathBoxNode
            let nodeWorldPosition = node.position
            let nodePositionOnScreen = renderer.projectPoint(nodeWorldPosition)
            let x = nodePositionOnScreen.x
            let y = nodePositionOnScreen.y
            
            let bitMask = Constants.BitMask.greenPath.rawValue | Constants.BitMask.redPath.rawValue
            let hitTest = renderer.hitTest(.init(x: CGFloat(x), y: CGFloat(y)), options: [.categoryBitMask : bitMask])
            
             if (hitTest.first?.node.geometry?.firstMaterial?.diffuse.contents as? UIColor) == UIColor.gray {
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            } else {
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            }
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            guard let breathingType = animationStartedBreathingType else {
                fatalError("Could not find animationStartedBreathingType")
            }
            MicrophoneManager.shared.breathingData.append(.init(breathingType: breathingType, value: 0, date: Date()))
            
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
        
        scene.background.contents = UIImage(named: "monk-1782432")!
        
        let focusNodeGeometry = SCNSphere(radius: 0.001)
        focusNode.geometry = focusNodeGeometry
        focusNode.worldPosition = SCNVector3(x: 0, y: 5, z: 0)
        scene.rootNode.addChildNode(focusNode)
        
        let boxGeometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
        breathBoxNode.geometry = boxGeometry
        breathBoxNode.worldPosition = SCNVector3(x: 0, y: 5, z: 0)
        breathBoxNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        breathBoxNode.geometry?.firstMaterial?.lightingModel = .blinn
        breathBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(Color.white)
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
        leftPipe.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        leftPipe.position = SCNVector3(-50, 0.1, 0)
        leftPipe.geometry?.firstMaterial?.lightingModel = .blinn
        scene.rootNode.addChildNode(leftPipe)
        
        let rightPipe = SCNNode()
        rightPipe.geometry = SCNBox(width: 4, height: 2, length: 100000, chamferRadius: 3)
        rightPipe.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        rightPipe.position = SCNVector3(50, 0.1, 0)
        rightPipe.geometry?.firstMaterial?.lightingModel = .blinn
        scene.rootNode.addChildNode(rightPipe)
        
        var totalZLength: CGFloat = 0
        for i in 0..<40 {
            
            let value = CGFloat.random(in: 50..<200)
            
            let planeWidth: CGFloat = 150
            let planeHeight: CGFloat = CGFloat(value) // 300 is 1.5s, 600 isx 3.0s, 200 per second
            let planeShape = SCNPlane(width: planeWidth, height: planeHeight)
            let planeShapeNode = SCNNode(geometry: planeShape)
            planeShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            planeShapeNode.geometry?.firstMaterial?.isDoubleSided = true
            planeShapeNode.worldPosition = SCNVector3.init(x: 0, y: -0.0001, z: Float(totalZLength) - (Float(planeHeight) / 2))
            planeShapeNode.eulerAngles = SCNVector3(CGFloat.pi * -0.5, 0.0, 0.0)
            
            totalZLength -= planeHeight
            
            let crossPathHeight: CGFloat = 40
            let crossPathGeo = SCNPlane(width: planeWidth - 48, height: crossPathHeight)
            let crossPathNode = SCNNode(geometry: crossPathGeo)
            crossPathNode.categoryBitMask = Constants.BitMask.greenPath.rawValue
            crossPathNode.position = SCNVector3.init(x: 0, y: (Float(planeHeight) / 2) - (Float(crossPathHeight) / 2), z: 0.1)
            crossPathNode.geometry?.firstMaterial?.lightingModel = .blinn
            crossPathNode.geometry?.firstMaterial?.diffuse.contents = UIColor(Color.accentColor)
            planeShapeNode.addChildNode(crossPathNode)
            
            let isEven = i % 2 == 0
            
            let goodSideHeight = planeHeight - crossPathHeight
            let goodSideWidth: CGFloat = (85 / 2)
            let goodPlaneShape = SCNPlane(width: goodSideWidth, height: goodSideHeight)
            let goodPlaneShapeNode = SCNNode(geometry: goodPlaneShape)
            goodPlaneShapeNode.categoryBitMask = Constants.BitMask.greenPath.rawValue
            goodPlaneShapeNode.position = SCNVector3.init(x: isEven ? -30 : 30, y: -((Float(crossPathHeight) / 2)), z: 0.1)
            goodPlaneShapeNode.geometry?.firstMaterial?.lightingModel = .blinn
            goodPlaneShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(Color.accentColor)
            planeShapeNode.addChildNode(goodPlaneShapeNode)
            
            let badSideHeight = planeHeight - crossPathHeight
            let badSideWidth: CGFloat = (120 / 2)
            let badPlaneShape = SCNBox(width: badSideWidth, height: badSideHeight, length: 3, chamferRadius: 0.5)
            let badPlaneShapeNode = SCNNode(geometry: badPlaneShape)
            badPlaneShapeNode.categoryBitMask = Constants.BitMask.redPath.rawValue
            badPlaneShapeNode.position = SCNVector3.init(x: isEven ? 20 : -20, y: -((Float(crossPathHeight) / 2)), z: 0.2)
            badPlaneShapeNode.geometry?.firstMaterial?.lightingModel = .blinn
            badPlaneShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            planeShapeNode.addChildNode(badPlaneShapeNode)
            
            scene.rootNode.addChildNode(planeShapeNode)
        }
        
        sceneView.rendersContinuously = true
        sceneView.scene = scene
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
