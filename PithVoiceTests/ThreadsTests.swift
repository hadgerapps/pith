import Foundation
@testable import PithVoice
import Testing

@Suite("Threads")
@MainActor
struct ThreadsTests {
    private func entry(daysAgo: Int, tags: [String], state: SummaryState = .ready) -> Entry {
        let when = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return Entry(createdAt: when, transcript: "x", summary: "y", tags: tags, summaryState: state)
    }

    @Test("ThreadPeriod.thisWeek filter")
    func thisWeekFilter() {
        let now = Date()
        let inWeek = Entry(createdAt: now)
        let lastWeek = Entry(createdAt: now.addingTimeInterval(-8 * 86_400))
        let filtered = ThreadPeriod.thisWeek.filter([inWeek, lastWeek], now: now)
        #expect(filtered.contains { $0 === inWeek })
        #expect(!filtered.contains { $0 === lastWeek })
    }

    @Test("ThemeClusterer ignores tags appearing only once")
    func themeMinOccurrences() {
        let entries = [
            entry(daysAgo: 0, tags: ["mom", "patience"]),
            entry(daysAgo: 1, tags: ["mom"]),
            entry(daysAgo: 2, tags: ["work"]),
        ]
        let themes = ThemeClusterer.themes(from: entries, period: .thisMonth)
        #expect(themes.contains { $0.label == "mom" })
        #expect(!themes.contains { $0.label == "work" })
        #expect(!themes.contains { $0.label == "patience" })
    }

    @Test("ThemeClusterer caps results at 4")
    func themeCap() {
        let entries = (0..<10).flatMap { idx -> [Entry] in
            let label = "t\(idx)"
            return [
                entry(daysAgo: idx * 2, tags: [label]),
                entry(daysAgo: idx * 2 + 1, tags: [label]),
            ]
        }
        let themes = ThemeClusterer.themes(from: entries, period: .thisMonth)
        #expect(themes.count <= ThemeClusterer.maxThemes)
    }

    @Test("ThemeClusterer ignores entries whose summary is pending or failed")
    func themeSkipsUnready() {
        let entries = [
            entry(daysAgo: 0, tags: ["mom"], state: .pending),
            entry(daysAgo: 1, tags: ["mom"], state: .failed),
            entry(daysAgo: 2, tags: ["mom"], state: .ready),
            entry(daysAgo: 3, tags: ["mom"], state: .ready),
        ]
        let themes = ThemeClusterer.themes(from: entries, period: .thisMonth)
        let mom = themes.first { $0.label == "mom" }
        #expect(mom?.count == 2)
    }
}
