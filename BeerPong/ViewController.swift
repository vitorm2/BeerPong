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

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var scene: SCNScene!
    var initalY: CGFloat = 0.0
    
    var ball: SCNNode!
    var container: SCNNode!
    var count = 0
    
    var gameHasStarted = false
    var gameHasFinished = false
    
    var cup1_showFlag: Bool = false
    var cup2_showFlag: Bool = false
    var cup3_showFlag: Bool = false
    var cup4_showFlag: Bool = false
    var cup5_showFlag: Bool = false
    var cup6_showFlag: Bool = false
    
    @IBOutlet weak var cup1_image: UIImageView!
    @IBOutlet weak var cup2_image: UIImageView!
    @IBOutlet weak var cup3_image: UIImageView!
    @IBOutlet weak var cup4_image: UIImageView!
    @IBOutlet weak var cup5_image: UIImageView!
    @IBOutlet weak var cup6_image: UIImageView!
    
    var isPlayingSong = false
    var isPlayingWinSong = false
    
    var hitCupSong: SCNAudioSource!
    var hitTable: SCNAudioSource!
    var tapPlaySong: SCNAudioSource!
    var winSong: SCNAudioSource!
    var themeSong: SCNAudioSource!
    
    @IBOutlet weak var cups_view: UIView!
    
    var directionalLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    var cameraNode: SCNNode!
    
    
    @IBOutlet weak var drinkMessage: UILabel!
    @IBOutlet weak var playAgainMessage: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        drinkMessage.text = "DRINK!"
        // Show statistics such as fps and timing information
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/MainScene.scn")!
        
        hitCupSong = SCNAudioSource(fileNamed: "hitCup.mp3")!
        hitTable = SCNAudioSource(fileNamed: "hitTable.mp3")!
        tapPlaySong = SCNAudioSource(fileNamed: "tapPlayButtonSong.mp3")!
        winSong = SCNAudioSource(fileNamed: "winSong.mp3")!
        themeSong = SCNAudioSource(fileNamed: "theme.mp3")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        cameraNode = SCNNode()
        cameraNode?.camera = SCNCamera()
        cameraNode?.position = SCNVector3(x: 0, y: 5, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false)!
        
        let swipeUpGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        pulsateButton()
        
        sceneView.addGestureRecognizer(swipeUpGesture)
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func pulsateButton() {
        playButton.pulsate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.pulsateButton()
        }
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
        self.scene.rootNode.runAction(SCNAction.playAudio(self.themeSong, waitForCompletion: false), forKey: "theme")
        
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
        
        
        if cup1_showFlag && cup2_showFlag && cup3_showFlag && cup4_showFlag && cup5_showFlag && cup6_showFlag{
            drinkMessage.text = "YOU WIN!"
            
            gameHasFinished = true
            DispatchQueue.main.async() {
                self.playAgainMessage.isHidden = false
                self.drinkMessage.isHidden = false
                if !self.isPlayingWinSong {
                    self.scene.rootNode.runAction(SCNAction.playAudio(self.winSong, waitForCompletion: true))
                    self.isPlayingWinSong = true
                }
            }
        }
    }
    
    @objc
    func handlePan(_ gestureRecognize: UISwipeGestureRecognizer) {
        
        if gameHasStarted {
            if gestureRecognize.state == .began {
                initalY = gestureRecognize.location(in: gestureRecognize.view).y
            } else if gestureRecognize.state == .ended {
                let finalY = gestureRecognize.location(in: gestureRecognize.view).y
                let displacement = initalY - finalY
                throwBall(displacement: displacement)
            }
        }
    }
    
    
    @IBAction func playButtonAction(_ sender: UIButton) {
       
       self.container.isHidden = false
        
         DispatchQueue.main.async() {
            self.playButton.isHidden = true
            self.cups_view.isHidden = false
           // self.container.isHidden = false
            
            self.scene.rootNode.removeAllAudioPlayers()
            self.scene.rootNode.runAction(SCNAction.playAudio(self.tapPlaySong, waitForCompletion: true))
        }
        
         gameHasStarted = true
    }
    
    
    func startNewGame(){
        let cup1: SCNNode = container.childNode(withName: "cup1", recursively: false)!
        let cup2: SCNNode = container.childNode(withName: "cup2", recursively: false)!
        let cup3: SCNNode = container.childNode(withName: "cup3", recursively: false)!
        let cup4: SCNNode = container.childNode(withName: "cup4", recursively: false)!
        let cup5: SCNNode = container.childNode(withName: "cup5", recursively: false)!
        let cup6: SCNNode = container.childNode(withName: "cup6", recursively: false)!
        
        cup1.isHidden = false
        cup2.isHidden = false
        cup3.isHidden = false
        cup4.isHidden = false
        cup5.isHidden = false
        cup6.isHidden = false
        
        
        cup1_showFlag = false
        cup2_showFlag = false
        cup3_showFlag = false
        cup4_showFlag = false
        cup5_showFlag = false
        cup6_showFlag = false
        
        DispatchQueue.main.async() {
            self.cup1_image.isHidden = false
            self.cup2_image.isHidden = false
            self.cup3_image.isHidden = false
            self.cup4_image.isHidden = false
            self.cup5_image.isHidden = false
            self.cup6_image.isHidden = false
            
            self.drinkMessage.isHidden = true
            self.playAgainMessage.isHidden = true
            self.drinkMessage.text = "DRINK!"
            self.scene.rootNode.runAction(SCNAction.playAudio(self.tapPlaySong, waitForCompletion: true))
        }
        isPlayingWinSong = false
        gameHasFinished = false
    }
    
    
    @objc
    func handleTap(_ gestureRecognize: UISwipeGestureRecognizer) {
        
        if !gameHasFinished {
            if gameHasStarted {
                throwBall(displacement: 30)
            }
        } else {
            startNewGame()
        }
    }
    
    func throwBall(displacement: CGFloat) {
        
        isPlayingSong = false
        drinkMessage.isHidden = true
        
        
        let randomY: Float = Float(displacement/50.0)

        guard let frame = sceneView.session.currentFrame else { return }
        let camMatrix = SCNMatrix4(frame.camera.transform)
        let direction = SCNVector3Make(-camMatrix.m31 * 5.0, randomY, (-camMatrix.m33 * 4.0))
        let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, (camMatrix.m43))

        let geometry: SCNGeometry = SCNSphere(radius: 0.02)
        let ballNode = SCNNode(geometry: geometry)
        ballNode.position = position
        ballNode.name = "ball"
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
        var ballObject: SCNNode!
        
        if contact.nodeA.physicsBody!.contactTestBitMask == 3 {
            contactObject = contact.nodeA
            ballObject = contact.nodeB
        } else {
            contactObject = contact.nodeB
            ballObject = contact.nodeA
        }
        
        
        switch contactObject.name {
        case "cup1_sensor":
            let cup: SCNNode = container.childNode(withName: "cup1", recursively: false)!
            cup.isHidden = true
            
            if !cup1_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                hiddenCupScore(cupNumber: 1)
                
            }
            cup1_showFlag = true
            
        case "cup2_sensor":
            let cup: SCNNode = container.childNode(withName: "cup2", recursively: false)!
            cup.isHidden = true
            
            if !cup2_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                 hiddenCupScore(cupNumber: 2)
            }
            cup2_showFlag = true
            
        case "cup3_sensor":
            let cup: SCNNode = container.childNode(withName: "cup3", recursively: false)!
            cup.isHidden = true
            
            if !cup3_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                 hiddenCupScore(cupNumber: 3)
            }
            cup3_showFlag = true
            
        case "cup4_sensor":
            let cup: SCNNode = container.childNode(withName: "cup4", recursively: false)!
            cup.isHidden = true
            
            if !cup4_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                 hiddenCupScore(cupNumber: 4)
            }
            cup4_showFlag = true
            
        case "cup5_sensor":
            let cup: SCNNode = container.childNode(withName: "cup5", recursively: false)!
            cup.isHidden = true
            
            if !cup5_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                 hiddenCupScore(cupNumber: 5)
            }
            cup5_showFlag = true
            
        case "cup6_sensor":
            let cup: SCNNode = container.childNode(withName: "cup6", recursively: false)!
            cup.isHidden = true
            
            if !cup6_showFlag {
                removeBallAndShowExplosion(ballObject: ballObject)
                 hiddenCupScore(cupNumber: 6)
            }
            cup6_showFlag = true
            
        case "tablePhysicsBody":
            if !isPlayingSong {
                 scene.rootNode.runAction(SCNAction.playAudio(hitTable, waitForCompletion: true))
                isPlayingSong = true
            }

        default:
            break
        }
    
    
    }
    
    func removeBallAndShowExplosion (ballObject: SCNNode) {
        
        
       
        DispatchQueue.main.async() {
            self.scene.rootNode.runAction(SCNAction.playAudio(self.hitCupSong, waitForCompletion: false))
            self.drinkMessage.isHidden = false
        }
    
        ballObject.removeFromParentNode()
        let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!
        explosion.particleSize = 0.001
        let explosionNode = SCNNode()
        explosionNode.position = ballObject.presentation.position
        sceneView.scene.rootNode.addChildNode(explosionNode)
        explosionNode.addParticleSystem(explosion)
    }
    
    func hiddenCupScore (cupNumber: Int) {
        switch cupNumber {
        case 1:
            DispatchQueue.main.async() {
                self.cup1_image.isHidden = true
            }
        case 2:
            DispatchQueue.main.async() {
                self.cup2_image.isHidden = true
            }
        case 3:
            DispatchQueue.main.async() {
                self.cup3_image.isHidden = true
            }
        case 4:
            DispatchQueue.main.async() {
                self.cup4_image.isHidden = true
            }
        case 5:
            DispatchQueue.main.async() {
                self.cup5_image.isHidden = true
            }
        case 6:
            DispatchQueue.main.async() {
                self.cup6_image.isHidden = true
            }
        default:
            break
        }
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}


extension UIButton {
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        
        pulse.duration = 100
        pulse.fromValue = 0.90
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
    
}
