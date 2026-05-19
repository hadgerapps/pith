import Foundation

// MARK: - ThreadPeriod

enum ThreadPeriod: String, CaseIterable, Identifiable {
    case thisWeek
    case lastWeek
    case thisMonth

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thisWeek: "This week"
        case .lastWeek: "Last week"
        case .thisMonth: "This month"
        }
    }

    /// Filter entries by their `createdAt` falling inside this period.
    func filter(_ entries: [Entry], now: Date = Date()) -> [Entry] {
        let calendar = Calendar.current
        switch self {
        case .thisWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
            return entries.filter { interval.contains($0.createdAt) }
        case .lastWeek:
            guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeek.start) ?? thisWeek.start
            let lastWeekEnd = thisWeek.start
            return entries.filter { $0.createdAt >= lastWeekStart && $0.createdAt < lastWeekEnd }
        case .thisMonth:
            guard let interval = calendar.dateInterval(of: .month, for: now) else { return [] }
            return entries.filter { interval.contains($0.createdAt) }
        }
    }
}

// MARK: - Theme

struct Theme: Identifiable, Hashable {
    let id: String
    let label: String
    let entries: [Entry]
    let oneLineSummary: String

    var count: Int { entries.count }
}

// MARK: - ThemeClusterer

/// Computes 3-4 strongest themes per period (FR-21) by tag frequency.
///
/// Semantic clustering via Foundation Models is mentioned in SPEC §FR-21
/// but deferred — v1.3 uses pure tag-frequency, which already captures the
/// "subjects of thought" semantics since the Distiller produces normalized
/// lowercase tags.
@MainActor
enum ThemeClusterer {
    static let maxThemes = 4
    static let minOccurrencesForTheme = 2

    /// Compute themes for a given period.
    static func themes(from entries: [Entry], period: ThreadPeriod, now: Date = Date()) -> [Theme] {
        let scoped = period.filter(entries, now: now)
        guard !scoped.isEmpty else { return [] }

        // Tag -> [entry] (entries that mention the tag)
        var byTag: [String: [Entry]] = [:]
        for entry in scoped where entry.summaryState == .ready {
            for tag in entry.tags {
                let key = tag.lowercased()
                byTag[key, default: []].append(entry)
            }
        }

        let ranked = byTag
            .filter { $0.value.count >= minOccurrencesForTheme }
            .sorted { lhs, rhs in
                if lhs.value.count == rhs.value.count {
                    return lhs.key < rhs.key
                }
                return lhs.value.count > rhs.value.count
            }
            .prefix(maxThemes)

        return ranked.map { tag, entries in
            Theme(
                id: tag,
                label: tag,
                entries: entries.sorted(by: { $0.createdAt > $1.createdAt }),
                oneLineSummary: oneLineSummary(entries: entries)
            )
        }
    }

    private static func oneLineSummary(entries: [Entry]) -> String {
        let count = entries.count
        if count == 1 {
            return "Once this week."
        }
        return "\(count) entries returned to this."
    }
}
