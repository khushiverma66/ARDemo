import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the ARSCNView
        sceneView = ARSCNView(frame: view.frame)
        sceneView.debugOptions = .showWireframe
        view.addSubview(sceneView)
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        configuration.sceneReconstruction = .meshWithClassification
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
            self.distanceLabel.text = String(format: "Distance: %.2f meters", distance)
        }
    }

    func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}

