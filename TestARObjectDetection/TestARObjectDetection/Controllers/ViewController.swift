//
//  ViewController.swift
//  TestARObjectDetection
//
//  Created by kokoheia on 2018/08/30.
//  Copyright © 2018年 kokoheia. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    static let appStateChangedNotification = Notification.Name("ApplicationStateChanged")
    static let appStateUserInfoKey = "AppState"
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    static var instance: ViewController?
    
    
    var internalState: State = .startARSession
    var scan: Scan?
    
    enum State {
        case startARSession
        case notReady
        case scanning
//        case testing
    }
    
    var state: State {
        get {
            return self.internalState
        }
        set {
            // 1. Check that preconditions for the state change are met.
            var newState = newValue
            switch newValue {
            case .startARSession:
                break
            case .notReady:
                // Immediately switch to .ready if tracking state is normal.
                if let camera = self.sceneView.session.currentFrame?.camera {
                    switch camera.trackingState {
                    case .normal:
                        newState = .scanning
                    default:
                        break
                    }
                } else {
                    newState = .startARSession
                }
            case .scanning:
                // Immediately switch to .notReady if tracking state is not normal.
                if let camera = self.sceneView.session.currentFrame?.camera {
                    switch camera.trackingState {
                    case .normal:
                        break
                    default:
                        newState = .notReady
                    }
                } else {
                    newState = .startARSession
                }
//            case .testing:
//                guard scan?.boundingBoxExists == true || referenceObjectToTest != nil else {
//                    print("Error: Scan is not ready to be tested.")
//                    return
//                }
            }
            
            // 2. Apply changes as needed per state.
            internalState = newState
            
            switch newState {
            case .startARSession:
                print("State: Starting ARSession")
                scan = nil
//                testRun = nil
//                modelURL = nil
//                self.setNavigationBarTitle("")
//                instructionsVisible = false
//                showBackButton(false)
//                nextButton.isEnabled = false
//                loadModelButton.isHidden = true
//                flashlightButton.isHidden = true
                
                // Make sure the SCNScene is cleared of any SCNNodes from previous scans.
                sceneView.scene = SCNScene()
                
                let configuration = ARObjectScanningConfiguration()
                configuration.planeDetection = .horizontal
                sceneView.session.run(configuration, options: .resetTracking)
//                cancelMaxScanTimeTimer()
//                cancelMessageExpirationTimer()
                
            case .notReady:
                print("State: Not ready to scan")
                scan = nil
//                testRun = nil
//                self.setNavigationBarTitle("")
//                loadModelButton.isHidden = true
//                flashlightButton.isHidden = true
//                showBackButton(false)
//                nextButton.isEnabled = false
//                nextButton.setTitle("Next", for: [])
//                displayInstruction(Message("Please wait for stable tracking"))
//                cancelMaxScanTimeTimer()
                
            case .scanning:
                print("State: Scanning")
                if scan == nil {
                    self.scan = Scan(sceneView)
                    self.scan?.state = .ready
                }
//                testRun = nil
//
//                startMaxScanTimeTimer()
//            case .testing:
//                print("State: Testing")
//                self.setNavigationBarTitle("Test")
//                loadModelButton.isHidden = true
//                flashlightButton.isHidden = false
//                showMergeScanButton()
//                nextButton.isEnabled = true
//                nextButton.setTitle("Share", for: [])
//
//                testRun = TestRun(sceneView: sceneView)
//                testObjectDetection()
//                cancelMaxScanTimeTimer()
            
            }
            
//            NotificationCenter.default.post(name: ViewController.appStateChangedNotification,
//                                            object: self,
//                                            userInfo: [ViewController.appStateUserInfoKey: self.state])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(scanningStateChanged), name: Scan.stateChangedNotification, object: nil)
        
        sceneView.delegate = self
        
//        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc
    func scanningStateChanged(_ notification: Notification) {
        guard self.state == .scanning, let scan = notification.object as? Scan, scan === self.scan else { return }
        guard let scanState = notification.userInfo?[Scan.stateUserInfoKey] as? Scan.State else { return }
        
        DispatchQueue.main.async {
            switch scanState {
            case .ready:
                print("State: Ready to scan")
//                self.setNavigationBarTitle("Ready to scan")
//                self.showBackButton(false)
//                self.nextButton.setTitle("Next", for: [])
//                self.loadModelButton.isHidden = true
//                self.flashlightButton.isHidden = true
//                if scan.ghostBoundingBoxExists {
//                    self.displayInstruction(Message("Tap 'Next' to create an approximate bounding box around the object you want to scan."))
//                    self.nextButton.isEnabled = true
//                } else {
//                    self.displayInstruction(Message("Point at a nearby object to scan."))
//                    self.nextButton.isEnabled = false
//                }
            case .defineBoundingBox:
                print("State: Define bounding box")
//                self.displayInstruction(Message("Position and resize bounding box using gestures.\n" +
//                "Long press sides to push/pull them in or out. "))
//                self.setNavigationBarTitle("Define bounding box")
//                self.showBackButton(true)
//                self.nextButton.isEnabled = scan.boundingBoxExists
//                self.loadModelButton.isHidden = true
//                self.flashlightButton.isHidden = true
//                self.nextButton.setTitle("Scan", for: [])
            case .scanning:
                print("scanning now")
//                self.displayInstruction(Message("Scan the object from all sides that you are " +
//                    "interested in. Do not move the object while scanning!"))
//                if let boundingBox = scan.scannedObject.boundingBox {
//                    self.setNavigationBarTitle("Scan (\(boundingBox.progressPercentage)%)")
//                } else {
//                    self.setNavigationBarTitle("Scan 0%")
//                }
//                self.showBackButton(true)
//                self.nextButton.isEnabled = true
//                self.loadModelButton.isHidden = true
//                self.flashlightButton.isHidden = true
//                self.nextButton.setTitle("Finish", for: [])
                // Disable plane detection (even if no plane has been found yet at this time) for performance reasons.
//                self.sceneView.stopPlaneDetection()
            case .adjustingOrigin:
                print("State: Adjusting Origin")
//                self.displayInstruction(Message("Adjust origin using gestures.\n" +
//                "You can load a *.usdz 3D model overlay."))
//                self.setNavigationBarTitle("Adjust origin")
//                self.showBackButton(true)
//                self.nextButton.isEnabled = true
//                self.loadModelButton.isHidden = false
//                self.flashlightButton.isHidden = true
//                self.nextButton.setTitle("Test", for: [])
            }
        }
    }
}
