import SwiftUI
import SceneKit

struct BreathPlayGameView: UIViewRepresentable {
    public let sceneView = SCNView()
    public let breathBoxNode = SCNNode()
    public let selfieStickNode = SCNNode()
    
    class Coordinator: NSObject, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
        let parent: BreathPlayGameView
        
        init(_ parent: BreathPlayGameView) {
            self.parent = parent
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            if let breathingType = MicrophoneManager.shared.breathingType {
                switch breathingType {
                case .inhale:
                    parent.breathBoxNode.geometry?.materials.first?.diffuse.contents = UIColor.green
                    
                case .exhale:
                    parent.breathBoxNode.geometry?.materials.first?.diffuse.contents = UIColor.blue
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        sceneView.delegate = context.coordinator
        
        let scene = SCNScene()
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.physicsBody = SCNPhysicsBody(
            type: .static, 
            shape: .init(geometry: SCNFloor(), options: nil)
        )
        floorNode.physicsBody?.categoryBitMask = Constants.BitMask.floor.rawValue
        floorNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        scene.rootNode.addChildNode(floorNode)
        
        let boxGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5)
        breathBoxNode.geometry = boxGeometry
        breathBoxNode.position = SCNVector3(x: 0, y: 1.5, z: 0)
        breathBoxNode.physicsBody = SCNPhysicsBody(
            type: .dynamic, 
            shape: .init(node: breathBoxNode, options: nil)
        )
        breathBoxNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        floorNode.addChildNode(breathBoxNode)
        
        selfieStickNode.camera = SCNCamera()
        selfieStickNode.position = SCNVector3(0, 8, 5)
        
        //camera constraints
        let distanceConstraint = SCNDistanceConstraint(target: breathBoxNode)
        distanceConstraint.minimumDistance = 30
        distanceConstraint.maximumDistance = 35
        let lookAtConstraint = SCNLookAtConstraint(target: breathBoxNode)
        lookAtConstraint.isGimbalLockEnabled = true
        selfieStickNode.constraints = [lookAtConstraint, distanceConstraint]
        scene.rootNode.addChildNode(selfieStickNode)
        
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
