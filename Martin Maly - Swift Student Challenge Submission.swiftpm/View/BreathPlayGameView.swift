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
                    parent.breathBoxNode.physicsBody?.applyForce(SCNVector3(x: 0, y:0, z: 0), asImpulse: true)
                    
                case .exhale: 
                    parent.breathBoxNode.physicsBody?.applyForce(SCNVector3(x: 0, y:0, z: -1), asImpulse: true)
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
        
        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.physicsBody = SCNPhysicsBody(
            type: .static, 
            shape: .init(geometry: SCNFloor(), options: nil)
        )
        floorNode.physicsBody?.categoryBitMask = Constants.BitMask.floor.rawValue
        floorNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        floorNode.geometry?.materials.first?.diffuse.contents = UIImage.init(named: "floor.jpeg")
        scene.rootNode.addChildNode(floorNode)
        
        let boxGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5)
        breathBoxNode.geometry = boxGeometry
        breathBoxNode.position = SCNVector3(x: 0, y: 1.5, z: 1.5)
        breathBoxNode.physicsBody = SCNPhysicsBody(
            type: .dynamic, 
            shape: .init(node: breathBoxNode, options: nil)
        )
        breathBoxNode.physicsBody?.collisionBitMask = Constants.BitMask.floor.rawValue
        floorNode.addChildNode(breathBoxNode)
        
        selfieStickNode.camera = SCNCamera()
        selfieStickNode.position = SCNVector3(0, 8, 5)
        scene.rootNode.addChildNode(selfieStickNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let cameraZoom = 40
        let cameraZPos = cameraZoom / 2 // cameraZoom == 100
        let replicatorConstraint = SCNReplicatorConstraint(target: breathBoxNode)
        replicatorConstraint.positionOffset = SCNVector3(0 ,cameraZoom, cameraZPos)
        replicatorConstraint.replicatesOrientation = false
        
        let lookAtConstraint = SCNLookAtConstraint(target: breathBoxNode)
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
            let planeHeight: CGFloat = 40
            let planeShape = SCNPlane(width: planeWidth, height: planeHeight)
            let planeShapeNode = SCNNode(geometry: planeShape)
            planeShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.random()
            
            planeShapeNode.position = SCNVector3.init(x: 0, y: 0.0001, z: -(Float(planeHeight) / 2) - (Float(i) * Float(planeHeight)))
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
