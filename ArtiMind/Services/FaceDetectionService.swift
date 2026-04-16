import Vision
import UIKit

struct FaceDetectionService {
    static func detectFaces(in image: UIImage) async -> [DetectedFace] {
        guard let cgImage = image.cgImage else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                guard let results = request.results as? [VNFaceObservation], error == nil else {
                    continuation.resume(returning: [])
                    return
                }

                let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
                var faces: [DetectedFace] = []

                for (index, observation) in results.enumerated() {
                    let bounds = CGRect(
                        x: observation.boundingBox.origin.x * imageSize.width,
                        y: (1 - observation.boundingBox.origin.y - observation.boundingBox.height) * imageSize.height,
                        width: observation.boundingBox.width * imageSize.width,
                        height: observation.boundingBox.height * imageSize.height
                    )

                    let expandedBounds = bounds.insetBy(
                        dx: -bounds.width * 0.3,
                        dy: -bounds.height * 0.3
                    ).intersection(CGRect(origin: .zero, size: imageSize))

                    if let croppedCG = cgImage.cropping(to: expandedBounds) {
                        faces.append(DetectedFace(
                            image: UIImage(cgImage: croppedCG),
                            bounds: bounds,
                            index: index
                        ))
                    }
                }
                continuation.resume(returning: faces)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
