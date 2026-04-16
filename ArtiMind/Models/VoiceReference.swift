import Foundation

struct VoiceReference: Identifiable, Hashable {
    let id = UUID()
    let emotion: VoiceEmotion
    let relationship: Relationship
    let fileName: String
    let url: URL

    var displayName: String {
        "\(emotion.displayName) — \(relationship.displayName)"
    }
}

enum VoiceEmotion: String, CaseIterable, Identifiable {
    case calmAttentive = "calm_attentive"
    case calmSincere = "calm_sincere"
    case gratefulSoft = "grateful_soft"
    case invitingWarm = "inviting_warm"
    case joyfulBright = "joyful_bright"
    case lovingGentle = "loving_gentle"
    case proudExcited = "proud_excited"
    case softCheerful = "soft_cheerful"
    case tenderCaring = "tender_caring"
    case upbeatSupportive = "upbeat_supportive"
    case warmFriendly = "warm_friendly"
    case warmLoving = "warm_loving"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calmAttentive: return "Calm & Attentive"
        case .calmSincere: return "Calm & Sincere"
        case .gratefulSoft: return "Grateful & Soft"
        case .invitingWarm: return "Inviting & Warm"
        case .joyfulBright: return "Joyful & Bright"
        case .lovingGentle: return "Loving & Gentle"
        case .proudExcited: return "Proud & Excited"
        case .softCheerful: return "Soft & Cheerful"
        case .tenderCaring: return "Tender & Caring"
        case .upbeatSupportive: return "Upbeat & Supportive"
        case .warmFriendly: return "Warm & Friendly"
        case .warmLoving: return "Warm & Loving"
        }
    }

    var icon: String {
        switch self {
        case .calmAttentive: return "ear.fill"
        case .calmSincere: return "heart.text.clipboard.fill"
        case .gratefulSoft: return "hands.sparkles.fill"
        case .invitingWarm: return "hand.wave.fill"
        case .joyfulBright: return "sun.max.fill"
        case .lovingGentle: return "heart.fill"
        case .proudExcited: return "star.fill"
        case .softCheerful: return "face.smiling.fill"
        case .tenderCaring: return "hand.raised.fill"
        case .upbeatSupportive: return "figure.walk"
        case .warmFriendly: return "cup.and.heat.waves.fill"
        case .warmLoving: return "heart.circle.fill"
        }
    }

    var color: (light: String, dark: String) {
        switch self {
        case .calmAttentive: return ("#7EC8E3", "#4A90B8")
        case .calmSincere: return ("#A8D5BA", "#6DAA8A")
        case .gratefulSoft: return ("#F5C6AA", "#D4956E")
        case .invitingWarm: return ("#FFD28F", "#E0A84D")
        case .joyfulBright: return ("#FFE066", "#D4B82E")
        case .lovingGentle: return ("#F8A4B8", "#D46A85")
        case .proudExcited: return ("#FFB347", "#D4862E")
        case .softCheerful: return ("#B5EAD7", "#78C9A5")
        case .tenderCaring: return ("#E8C8F0", "#BA8AC8")
        case .upbeatSupportive: return ("#87CEEB", "#5AA0C0")
        case .warmFriendly: return ("#FFDAB9", "#D4A872")
        case .warmLoving: return ("#FFB6C1", "#D47A88")
        }
    }
}
