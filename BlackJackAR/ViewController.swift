//
//  ViewController.swift
//  BlackJackAR
//
//  Created by Zsolt Pete on 2017. 08. 05..
//  Copyright © 2017. Zsolt Pete. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    var cards = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        self.registerGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func makeTable(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touch = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(touch, options: [:])
        
        if !hitResults.isEmpty {
            guard let firstHitResult = hitResults.first else {
                return
            }
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 31/255, green: 93/255, blue: 70/255, alpha: 1.0)
            guard let firstPlane = self.planes.first else {
                return
            }
            firstPlane.planeGeometry.materials = [material]
            sceneView.delegate = nil
            self.planes.removeAll()
            self.planes.append(firstPlane)
        }
    }
    
    func initDeck(hitResult :ARHitTestResult){
            let card: SCNBox = SCNBox(width: 0.06350, height: 0.052, length: 0.0889, chamferRadius: 0.0)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "card_background")
            card.materials = [ SCNMaterial(), SCNMaterial(), SCNMaterial(), SCNMaterial(), material, SCNMaterial()]
            let boxNode = SCNNode(geometry: card)
            boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            boxNode.physicsBody?.categoryBitMask = 1
            boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(0.1), hitResult.worldTransform.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(boxNode)
            self.cards.append(boxNode)
        
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            initDeck(hitResult :hitResult)
        }
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
}
