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
    var scene: SCNScene!
    var initalY: CGFloat = 0.0
    
    var ball: SCNNode!
    
    var count = 0
    
    @IBOutlet weak var messageLabel: UILabel!
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
    
        
//        createBall()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        let swipeUpGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        sceneView.scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.contactDelegate = self
        
        sceneView.addGestureRecognizer(swipeUpGesture)
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         sceneView.session.delegate = self
        
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
            throwBall(displacement: displacement, finalX: finalX)
        }
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UISwipeGestureRecognizer) {
        
      throwBall(displacement: 10, finalX: 0)
        
    }
    
    func throwBall(displacement: CGFloat, finalX: CGFloat) {
        
//        let geometry: SCNGeometry = SCNSphere(radius: 0.02)
//        ball = SCNNode(geometry: geometry)
//
//        geometry.materials.first?.diffuse.contents = UIColor.white
//        ball.position = SCNVector3(0, 0, -0.5)
//        ball.physicsBody?.contactTestBitMask = 1
//        ball.physicsBody?.categoryBitMask = 3
//        ball.physicsBody?.collisionBitMask = -1
//
//        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        sceneView.pointOfView?.addChildNode(ball)
        let randomY: Float = Float(displacement/30.0)
//        let randomX: Float = Float(finalX/20)
//
//        print(finalX)
//
//        let force = SCNVector3(x: randomX, y: randomY , z: -2.5)
//
//        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
//
//        ball.physicsBody?.applyForce(force, at: position, asImpulse: true)
//        ball.runAction(SCNAction.sequence([SCNAction.wait(duration: 3.0), SCNAction.removeFromParentNode()])) //5


        guard let frame = sceneView.session.currentFrame else { return }
        let camMatrix = SCNMatrix4(frame.camera.transform)
        let direction = SCNVector3Make(-camMatrix.m31 * 5.0, randomY, (-camMatrix.m33 * 4.0))
        let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, (camMatrix.m43))

        let geometry: SCNGeometry = SCNSphere(radius: 0.02)
        let ballNode = SCNNode(geometry: geometry)
        ballNode.position = position
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        ballNode.physicsBody?.categoryBitMask = 3
        ballNode.physicsBody?.contactTestBitMask = 1
        ballNode.physicsBody?.collisionBitMask = -1
        sceneView.scene.rootNode.addChildNode(ballNode)
        ballNode.physicsBody?.applyForce(direction, asImpulse: true)
        ballNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.removeFromParentNode()]))

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

extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var contactObject: SCNNode!
        
        if contact.nodeA.physicsBody!.contactTestBitMask == 3 {
            contactObject = contact.nodeA
        } else {
            contactObject = contact.nodeB
        }
        
        
        
        
        if contactObject.name == "cup1_sensor" {
            //messageLabel.isHidden = false
            
            count = count + 1
            messageLabel.text = String(count)
            
        }
       
    }
}





