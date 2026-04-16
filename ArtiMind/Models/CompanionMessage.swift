import Foundation

struct CompanionMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var voiceURL: URL?

    init(content: String, isUser: Bool, voiceURL: URL? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = .now
        self.voiceURL = voiceURL
    }
}
