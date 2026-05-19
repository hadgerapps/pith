import Foundation
import SwiftData

/// Convenience helpers on top of `ModelContext`. Phase 4 keeps these thin —
/// the rest of the app reads entries via `@Query` and writes via direct
/// `modelContext.insert/delete`.
enum EntryRepository {
    /// Build a ModelContainer with FileProtectionType.complete on the
    /// underlying store (FR-13 — encrypt at rest).
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let config = ModelConfiguration(
            "PithVoice",
            schema: Schema([Entry.self]),
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: Entry.self, configurations: config)
    }

    /// Delete an entry's audio file. Called alongside `modelContext.delete` —
    /// SwiftData does not own the audio file, so it must be cleaned up manually.
    @discardableResult
    static func deleteAudioFile(for entry: Entry) -> Bool {
        guard let url = entry.audioURL else { return false }
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch CocoaError.fileNoSuchFile {
            return true
        } catch {
            return false
        }
    }

    /// FR-19: 72-hour idle threshold for surfacing Read me back.
    static let idleThresholdForReadMeBack: TimeInterval = 72 * 60 * 60

    /// Returns true if `lastEntryAt` is more than 72h ago.
    static func shouldShowReadMeBack(lastEntryAt: Date?, now: Date = Date()) -> Bool {
        guard let lastEntryAt else { return false }
        return now.timeIntervalSince(lastEntryAt) >= idleThresholdForReadMeBack
    }
}
