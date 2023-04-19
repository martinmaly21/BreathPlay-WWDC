import SwiftUI
import SceneKit

struct BreathPlayGameView: UIViewRepresentable {
    public let sceneView = SCNView()
    public let breathBoxNode = SCNNode()
    public let focusNode = SCNNode()
    public let selfieStickNode = SCNNode()
    
    class Coordinator: NSObject, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
        let parent: BreathPlayGameView
        var timer = Timer()
        
        init(_ parent: BreathPlayGameView) {
            self.parent = parent
            super.init()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                let offset: Float = 30
                
                if let breathingType = MicrophoneManager.shared.breathingType {
                    switch breathingType {
                    case .inhale: 
                        parent.breathBoxNode.position.x = offset
                    case .exhale: 
                        parent.breathBoxNode.position.x = -offset
                    }
                }
                
                parent.breathBoxNode.position.z -= 2
                parent.focusNode.position.z -= 2
            })
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            //
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
        
        let boxGeometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1)
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

        for i in 0..<200 {
            //5 segments
            //add plane
            //negative z will be our 'forward' direction
            let planeWidth: CGFloat = 150
            let planeHeight: CGFloat = 180
            let planeShape = SCNPlane(width: planeWidth, height: planeHeight)
            let planeShapeNode = SCNNode(geometry: planeShape)
            planeShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.random()
            planeShapeNode.geometry?.firstMaterial?.isDoubleSided = true
            planeShapeNode.position = SCNVector3.init(x: 0, y: -0.0001, z: -(Float(planeHeight) / 2) - (Float(i) * Float(planeHeight)))
            planeShapeNode.eulerAngles = SCNVector3(CGFloat.pi * -0.5, 0.0, 0.0)
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
