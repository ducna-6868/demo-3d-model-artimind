import AVFoundation
import Foundation

@Observable
final class VoiceService {
    private var audioPlayer: AVAudioPlayer?
    var isPlaying = false
    var currentVoice: VoiceReference?

    func loadVoiceLibrary() -> [VoiceEmotion: [VoiceReference]] {
        var library: [VoiceEmotion: [VoiceReference]] = [:]
        let basePath = "/Users/ducna/Downloads/voice_reference"

        for emotion in VoiceEmotion.allCases {
            let emotionPath = "\(basePath)/\(emotion.rawValue)"
            let relationships: [(String, Relationship)] = [
                ("father.mp3", .father),
                ("mother.mp3", .mother),
                ("grandfather.mp3", .grandfather),
                ("grandmother.mp3", .grandmother)
            ]

            var voices: [VoiceReference] = []
            for (file, rel) in relationships {
                let url = URL(fileURLWithPath: "\(emotionPath)/\(file)")
                if FileManager.default.fileExists(atPath: url.path) {
                    voices.append(VoiceReference(
                        emotion: emotion,
                        relationship: rel,
                        fileName: file,
                        url: url
                    ))
                }
            }
            if !voices.isEmpty {
                library[emotion] = voices
            }
        }
        return library
    }

    func play(_ voice: VoiceReference) {
        stop()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: voice.url)
            audioPlayer?.play()
            isPlaying = true
            currentVoice = voice
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentVoice = nil
    }
}
