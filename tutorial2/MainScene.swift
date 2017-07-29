//
//  MainScene.swift
//  ARTest1
//
//  Created by Daniel Wyszynski on 7/22/17.
//  Copyright © 2017 Aboveground Systems, LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainScene {

    var scene: SCNScene?
    var planes = [ARPlaneAnchor: SCNNode]()

    init() {
        scene = self.initializeScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        scene = self.initializeScene()
    }
    
    func initializeScene() -> SCNScene? {
        let scene = SCNScene()
        
        setDefaults(scene: scene)
        
        return scene
    }
    
    func setDefaults(scene: SCNScene) {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 1000

        let directionalNode = SCNNode()
        directionalNode.name = "__directionalLight"
        directionalNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-130), GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(-35))
        directionalNode.light = directionalLight
        scene.rootNode.addChildNode(directionalNode)
    }
    
    func addBlockToPos(position: SCNVector3, imageName: String) {
        
        guard let scene = self.scene else { return }

        let blockNode = SCNNode()
        blockNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        blockNode.geometry?.firstMaterial?.diffuse.contents = imageName // Can either do a string for the filename, or the actual UIImage
        blockNode.castsShadow = true
        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        (minVec, maxVec) =  blockNode.boundingBox
        let bounds = SCNVector3(
                x: maxVec.x - minVec.x,
                y: maxVec.y - minVec.y,
                z: maxVec.z - minVec.z)
        blockNode.pivot = SCNMatrix4MakeTranslation(0, -bounds.y / 2, 0)
        blockNode.position = position
        scene.rootNode.addChildNode(blockNode)
    }
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        // Create a SceneKit plane to visualize the node using its position and extent.
        
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))

        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor(red: 65/255, green: 255/255, blue: 255/255, alpha: 0.4)
        plane.materials = [planeMaterial]
        
        // Create a node with the plane geometry we created
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)

        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

        planes[anchor] = planeNode

        print("[NEW SURFACE DETECTED] New count: \(planes.count)")
        return planeNode
    }

    func updatePlaneNode(anchor: ARPlaneAnchor) {
        // Resize the plane
        if let plane = planes[anchor], let geometry = plane.geometry as? SCNPlane {
            geometry.width = CGFloat(anchor.extent.x)
            geometry.height = CGFloat(anchor.extent.z)
            
            let scaledWidth: Float = Float(geometry.width / 2.4)
            let scaledHeight: Float = Float(geometry.height / 2.4)
            
            let offsetWidth: Float = -0.5 * (scaledWidth - 1)
            let offsetHeight: Float = -0.5 * (scaledHeight - 1)
            
            let material = geometry.materials.first
            var transform = SCNMatrix4MakeScale(scaledWidth, scaledHeight, 1)
            transform = SCNMatrix4Translate(transform, offsetWidth, offsetHeight, 0)
            material?.diffuse.contentsTransform = transform
        }

    }
    
    func removePlaneNode(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
    func updateScene(_ camera: ARCamera, sceneView: SCNView, screenCenter: CGPoint) {
        // Stub for future fun stuff :)
    }
    
}


