import SwiftUI
import SceneKit


class LevelSegmentNode: SCNNode {
    //5 segments
    //add plane
    //negative z will be our 'forward' direction

    
    init(indexOfSegment: Int, breathingType: BreathingType) {
        super.init()
        let planeWidth: CGFloat = 150
        let planeHeight: CGFloat = 180
        let planeShape = SCNPlane(width: planeWidth, height: planeHeight)
        let planeShapeNode = SCNNode(geometry: planeShape)
        planeShapeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.random()
        planeShapeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeShapeNode.position = SCNVector3.init(x: 0, y: -0.0001, z: -(Float(planeHeight) / 2) - (Float(indexOfSegment) * Float(planeHeight)))
        planeShapeNode.eulerAngles = SCNVector3(CGFloat.pi * -0.5, 0.0, 0.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
