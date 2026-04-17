import Foundation

struct CompanionMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var voiceURL: URL?
    var voiceDurationSeconds: Int?

    init(content: String, isUser: Bool, voiceURL: URL? = nil, voiceDurationSeconds: Int? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = .now
        self.voiceURL = voiceURL
        self.voiceDurationSeconds = voiceDurationSeconds
    }
}
