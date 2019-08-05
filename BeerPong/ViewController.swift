//
//  ViewController.swift
//  RingToss
//
//  Created by Vitor Demenighi on 01/08/19.
//  Copyright © 2019 Vitor Demenighi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var ringQueue: [SCNNode] = []
    var scene: SCNScene!
    var initalY: CGFloat = 0.0
    
    var directionalLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/MainScene.scn")!
        
        
        sceneView.debugOptions = SCNDebugOptions.showPhysicsShapes
        
        createRing()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        let swipeUpGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(swipeUpGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ambientLightNode = sceneView.scene.rootNode.childNode(withName: "ambientLight", recursively: false)
        directionalLightNode = sceneView.scene.rootNode.childNode(withName: "directionalLight", recursively: false)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
       
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let lightEstimate = frame.lightEstimate else { return }
        ambientLightNode?.light?.intensity = lightEstimate.ambientIntensity * 0.4
        directionalLightNode?.light?.intensity = lightEstimate.ambientIntensity
    }
    
    @objc
    func handlePan(_ gestureRecognize: UISwipeGestureRecognizer) {
        
        if gestureRecognize.state == .began {
            initalY = gestureRecognize.location(in: gestureRecognize.view).y
        } else if gestureRecognize.state == .ended {
            let finalY = gestureRecognize.location(in: gestureRecognize.view).y
            let finalX = gestureRecognize.location(in: gestureRecognize.view).x
            let displacement = initalY - finalY
            throwRing(displacement: displacement, finalX: finalX)
        }
        
    }
    
    func throwRing(displacement: CGFloat, finalX: CGFloat) {
        
        ringQueue.last?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        let randomY: Float = Float(displacement/30.0)
        let randomX: Float = 0

        let force = SCNVector3(x: randomX, y: randomY , z: -2.0)
        // 3
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        // 4

        ringQueue.last?.physicsBody?.applyForce(force, at: position, asImpulse: true)


//        guard let frame = sceneView.session.currentFrame else { return }
//        let camMatrix = SCNMatrix4(frame.camera.transform)
//        let direction = SCNVector3Make(-camMatrix.m31 * 5.0, -camMatrix.m32 * 10.0, (-camMatrix.m33 * 5.0))
//        let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, (camMatrix.m43))
//
//        let ballNode = ringQueue.last!
//        ballNode.position = position
//        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        ballNode.physicsBody?.categoryBitMask = 3
//        ballNode.physicsBody?.contactTestBitMask = 1
//        sceneView.scene.rootNode.addChildNode(ballNode)
//        ballNode.physicsBody?.applyForce(direction, asImpulse: true)
//
//
    }
    
    func createRing() {
        let geometry: SCNGeometry = SCNSphere(radius: 0.02)
        let newRing = SCNNode(geometry: geometry)
        geometry.materials.first?.diffuse.contents = UIColor.white
        newRing.position = SCNVector3(0, -0.5, -1)
        newRing.physicsBody?.collisionBitMask =  0
        newRing.physicsBody?.contactTestBitMask = 0

        sceneView.pointOfView?.addChildNode(newRing)

        ringQueue.append(newRing)
    }

    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
}



