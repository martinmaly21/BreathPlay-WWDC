import SwiftUI
import SceneKit

struct BreathPlayGameView: UIViewRepresentable {
    class Coordinator: NSObject, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
        let sceneView: SCNView
        
        init(_ sceneView: SCNView) {
            self.sceneView = sceneView
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            let boxNode = sceneView.scene?.rootNode.childNode(withName: "Box", recursively: true)
            
            if let breathingType = MicrophoneManager.shared.breathingType {
                switch breathingType {
                case .inhale:
                    if boxNode?.geometry?.materials.first?.diffuse.contents as! UIColor != UIColor.green {
                        boxNode?.geometry?.materials.first?.diffuse.contents = UIColor.green
                    }
                case .exhale:
                    if boxNode?.geometry?.materials.first?.diffuse.contents as! UIColor != UIColor.blue {
                         boxNode?.geometry?.materials.first?.diffuse.contents = UIColor.blue
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(SCNView())
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = context.coordinator.sceneView
        sceneView.delegate = context.coordinator
        
        let scene = SCNScene()
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()

        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        cameraNode.camera
        
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
        scene.rootNode.addChildNode(floorNode)
        
        let boxGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"
        boxNode.geometry?.materials.first?.diffuse.contents = UIColor.red
        boxNode.position = SCNVector3(x: 0, y: 2, z: 0)
        floorNode.addChildNode(boxNode)
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
