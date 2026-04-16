import SwiftUI
import Foundation

@Observable
final class LovedOne: Identifiable {
    let id = UUID()
    var name: String
    var relationship: Relationship
    var photo: UIImage?
    var detectedFaces: [DetectedFace] = []
    var selectedFaceIndex: Int?
    var selectedVoice: VoiceReference?
    var memoryMedia: [UIImage] = []
    var memoryText: String = ""
    var model3DURL: URL?
    var isGenerated: Bool = false

    init(name: String = "", relationship: Relationship = .custom) {
        self.name = name
        self.relationship = relationship
    }
}

enum Relationship: String, CaseIterable, Identifiable {
    case father, mother, grandfather, grandmother, custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .father: return "Father"
        case .mother: return "Mother"
        case .grandfather: return "Grandfather"
        case .grandmother: return "Grandmother"
        case .custom: return "Someone Special"
        }
    }

    var icon: String {
        switch self {
        case .father: return "figure.stand"
        case .mother: return "figure.stand.dress"
        case .grandfather: return "figure.stand"
        case .grandmother: return "figure.stand.dress"
        case .custom: return "heart.fill"
        }
    }
}

struct DetectedFace: Identifiable {
    let id = UUID()
    let image: UIImage
    let bounds: CGRect
    let index: Int
}
