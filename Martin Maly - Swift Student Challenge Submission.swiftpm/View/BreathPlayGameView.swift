import SwiftUI
import SceneKit

struct BreathPlayGameView: UIViewRepresentable {
    @Binding var breathingType: BreathingType?
    
    class Coordinator: NSObject, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
        let sceneView: SCNView
        
        init(_ sceneView: SCNView) {
            self.sceneView = sceneView
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // This is called every frame, put your per-frame logic here
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(SCNView())
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = context.coordinator.sceneView
        sceneView.delegate = context.coordinator
        
        let scene = SCNScene(named: "ball.scn")!
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
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
        
        print(scene.rootNode.childNodes)
        let ship = scene.rootNode.childNode(withName: "sphere", recursively: true)!
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let material = context.coordinator.sceneView.scene?.rootNode.childNodes[0].geometry?.firstMaterial {
            if let breathingType = breathingType {
                material.emission.contents = breathingType == .inhale ? UIColor.green : UIColor.red
            }
        }
    }
}
