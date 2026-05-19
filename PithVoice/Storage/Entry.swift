import Foundation
import SwiftData

// MARK: - Entry

/// SwiftData model for a single journal entry (FR-12).
///
/// All fields stored locally. Audio file lives at
/// `Documents/audio/<audioFilename>` with `NSFileProtectionComplete` (FR-13).
@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var duration: TimeInterval
    var audioFilename: String
    var transcript: String
    var summary: String?
    var tags: [String]
    var summaryStateRaw: String
    var userTitle: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        duration: TimeInterval = 0,
        audioFilename: String = "",
        transcript: String = "",
        summary: String? = nil,
        tags: [String] = [],
        summaryState: SummaryState = .pending,
        userTitle: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.audioFilename = audioFilename
        self.transcript = transcript
        self.summary = summary
        self.tags = tags
        summaryStateRaw = summaryState.rawValue
        self.userTitle = userTitle
    }

    /// Typed accessor for the underlying raw value.
    var summaryState: SummaryState {
        get { SummaryState(rawValue: summaryStateRaw) ?? .pending }
        set { summaryStateRaw = newValue.rawValue }
    }

    /// Title shown on cards: user title if set, else first words of transcript.
    var displayTitle: String {
        if let userTitle, !userTitle.isEmpty {
            return userTitle
        }
        let words = transcript.split(separator: " ").prefix(8).joined(separator: " ")
        return words.isEmpty ? "Untitled" : String(words)
    }

    /// Full audio URL (resolved against Documents at access time — never store
    /// absolute URLs in the model since the sandbox path can change across
    /// reinstalls).
    var audioURL: URL? {
        guard !audioFilename.isEmpty else { return nil }
        return Recorder.documentsAudioDirectory().appendingPathComponent(audioFilename)
    }

    /// Duration formatted as "4 min" or "12 sec".
    var durationDisplay: String {
        if duration < 60 {
            return "\(Int(duration)) sec"
        }
        return "\(Int(duration / 60)) min"
    }
}
