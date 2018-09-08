//
//  ViewController.swift
//  ARHacking
//
//  Created by Martin Mitrevski on 08.09.18.
//  Copyright © 2018 Mitrevski. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    static let jackVideo = Bundle.main.url(forResource: "video2", withExtension: "mp4")!
    static let ballantinesVideo = Bundle.main.url(forResource: "video1", withExtension: "mp4")!
    let players = [ "jack" : AVPlayer(url: jackVideo),
                    "ballantines" : AVPlayer(url: ballantinesVideo)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        self.sceneView.scene = scene
        sceneView.delegate = self
        for (_, player) in players {
            videoObserver(for: player)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupImageTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupImageTrackingConfiguration() {
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Whiskies", bundle: Bundle.main)!
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 2
        sceneView.session.run(configuration)
    }
    
    func videoObserver(for videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil, queue: nil) { notification in
            videoPlayer.seek(to: CMTime.zero)
        }
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let player = players[imageAnchor.name!]!
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = player
            player.seek(to: CMTime.zero)
            player.play()
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        if let pointOfView = sceneView.pointOfView {
            let isVisible = sceneView.isNode(node, insideFrustumOf: pointOfView)
            if isVisible {
                let player = players[imageAnchor.name!]!
                if player.rate == 0 {
                    player.play()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
