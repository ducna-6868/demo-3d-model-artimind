import SceneKit
import Foundation

@MainActor
final class SceneService {
    static let shared = SceneService()
    private init() {}

    private let modelPath = "/Users/ducna/Downloads/riggedmesh.glb"

    func loadScene() -> SCNScene? {
        let url = URL(fileURLWithPath: modelPath)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        do {
            let scene = try SCNScene(url: url, options: [
                .checkConsistency: true,
                .convertToYUp: true
            ])
            configureScene(scene)
            return scene
        } catch {
            return createPlaceholderScene()
        }
    }

    private func configureScene(_ scene: SCNScene) {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1)
        scene.rootNode.addChildNode(ambientLight)

        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor(white: 0.9, alpha: 1)
        directionalLight.light?.castsShadow = true
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directionalLight)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 45
        camera.position = SCNVector3(0, 1.2, 2.5)
        camera.look(at: SCNVector3(0, 0.8, 0))
        scene.rootNode.addChildNode(camera)
    }

    private func createPlaceholderScene() -> SCNScene {
        let scene = SCNScene()
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemPurple.withAlphaComponent(0.6)
        sphere.firstMaterial?.transparency = 0.8

        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, 1, 0)
        scene.rootNode.addChildNode(node)

        configureScene(scene)
        return scene
    }
}
