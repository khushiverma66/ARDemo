//
//  RealityKitViewController.swift
//  ARDemo
//
//  Created by Khushi Verma on 01/05/24.
//

import UIKit
import ARKit
import RealityKit

class RealityKitViewController: UIViewController , ARSCNViewDelegate {
    var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.frame)
        sceneView.delegate = self
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .vertical
//        configuration.sceneReconstruction = .meshWithClassification
        
        // Run the view's session
      

        let arView = ARView(frame: view.frame,
                                    cameraMode: .ar,
                                            automaticallyConfigureSession: false)

                arView.automaticallyConfigureSession = false
                let configuration = ARWorldTrackingConfiguration()
                configuration.sceneReconstruction = .meshWithClassification
                configuration.planeDetection = [.vertical]
                arView.debugOptions.insert(.showSceneUnderstanding)
                view.addSubview(arView)

                arView.debugOptions = [.showWorldOrigin, .showSceneUnderstanding]
        
           //     arView.session.run(configuration)
        sceneView.session.run(configuration)

        // Do any additional setup after loading the view.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Get the device position
            guard let frame = self.sceneView.session.currentFrame else {
                return
            }
            let cameraTransform = frame.camera.transform
            
            // Perform raycasting query to find existing plane at the center of the screen
            let query = self.sceneView.raycastQuery(from: self.sceneView.center, allowing: .existingPlaneGeometry, alignment: .any)
            guard let raycastQuery = query else {
                return
            }
            let results = self.sceneView.session.raycast(raycastQuery)
            
            // Get the hit coordinates
            guard let result = results.first else {
                return
            }
            let hitTransform = result.worldTransform
            
            // Get the translation vectors from the transformation matrices
            let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let hitPosition = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
            
            // Calculate distance
            let distance = self.calculateDistance(cameraPosition, hitPosition)
            
            // Now you have the distance, you can use it as needed
            print("Distance between camera and hit point: \(distance)")
         //   self.distanceLabel.text = String(format: "Distance: %.2f meters", distance)
        }
    }

    func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}
