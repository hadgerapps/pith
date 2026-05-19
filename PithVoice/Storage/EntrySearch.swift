import Foundation

/// Text and tag matching for entry search (FR-20). The SPEC describes a
/// three-tier search: tag match (instant), transcript text match (instant),
/// semantic similarity via FoundationModels (~1-3 s). v1.3 implements the
/// first two; semantic tier lands in v1.1 once embedding APIs stabilise.
enum EntrySearch {
    /// Filter entries by query — case-insensitive substring match across
    /// transcript, summary, tags, and user title.
    static func filter(_ entries: [Entry], query: String) -> [Entry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return entries }
        let needle = trimmed.lowercased()
        return entries.filter { entry in
            entry.transcript.lowercased().contains(needle)
                || (entry.summary?.lowercased().contains(needle) ?? false)
                || entry.tags.contains { $0.lowercased().contains(needle) }
                || (entry.userTitle?.lowercased().contains(needle) ?? false)
        }
    }

    /// Highlight ranges in a string for SwiftUI attributed-string emphasis.
    static func highlightRanges(in text: String, query: String) -> [Range<String.Index>] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }
        let lower = text.lowercased()
        var ranges: [Range<String.Index>] = []
        var cursor = lower.startIndex
        while let range = lower.range(of: trimmed, range: cursor..<lower.endIndex) {
            ranges.append(range)
            cursor = range.upperBound
        }
        return ranges
    }
}
