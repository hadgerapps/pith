import Foundation
import SwiftData

/// Seed deterministic demo data for App Store screenshot capture.
///
/// Activated by launch argument `-uitest-seed`. Inserts 3 fake entries
/// with realistic summaries + tags, marks onboarding completed, and
/// optionally routes the app to a specific screen via `-uitest-screen`.
///
/// Production users never pass these args, so the path is dormant.
enum UITestSeed {
    /// Read once at app launch.
    static let isRequested: Bool = {
        CommandLine.arguments.contains("-uitest-seed")
    }()

    /// Optional initial route — `today` (default), `threads`, `detail`,
    /// `paywall`, `record`.
    static let route: Route = {
        guard let idx = CommandLine.arguments.firstIndex(of: "-uitest-screen"),
              idx + 1 < CommandLine.arguments.count,
              let r = Route(rawValue: CommandLine.arguments[idx + 1])
        else { return .today }
        return r
    }()

    enum Route: String {
        case today, threads, detail, paywall, record
    }

    /// Build 3 demo entries spanning the last three days. Past tense
    /// summaries, lowercase tags — matches SPEC § Foundation Models guide.
    static func entries() -> [Entry] {
        let now = Date()
        let d1 = now.addingTimeInterval(-1 * 60 * 60 * 3)
        let d2 = now.addingTimeInterval(-1 * 86_400 - 60 * 60)
        let d3 = now.addingTimeInterval(-2 * 86_400 - 60 * 60 * 4)
        return [
            Entry(
                id: UUID(),
                createdAt: d1,
                duration: 3 * 60 + 14,
                audioFilename: "uitest-seed-1.m4a",
                transcript: "Sat in the kitchen, kettle on. I keep thinking about last night — Mom called from the hospital but she didn't ask the question. She didn't ask if I'd thought any more about Dad. I'd been waiting for it. The space where the question should have been sat between us for an hour. I'm not angry. I just noticed I was waiting.",
                summary: "Talked about the conversation with Mom on the phone last night — what wasn't said, what I was hoping she'd ask. Sat with it.",
                tags: ["mom", "expectations", "morning"],
                summaryState: .ready,
                userTitle: "The hour before the meeting"
            ),
            Entry(
                id: UUID(),
                createdAt: d2,
                duration: 4 * 60 + 38,
                audioFilename: "uitest-seed-2.m4a",
                transcript: "Walked home from the studio the long way. The thought I keep coming back to: the difference between being patient and being slow. They're not the same. Patient is staying with something. Slow is not moving. I have been slow with the writing for weeks, and calling it patience.",
                summary: "Caught a recurring thought — patience and slowness are not the same. The writing has been slow and called patient.",
                tags: ["patience", "work"],
                summaryState: .ready,
                userTitle: "After the walk home"
            ),
            Entry(
                id: UUID(),
                createdAt: d3,
                duration: 5 * 60 + 2,
                audioFilename: "uitest-seed-3.m4a",
                transcript: "James said something at dinner that stayed. He said: a boundary that needs to be defended every day isn't a boundary, it's a wall. I'm holding it lightly. I think there are walls I've been calling boundaries with my brother. I'm not ready to do anything about it. But I noticed.",
                summary: "James's line about boundaries vs walls. Held it lightly. Noticed how it applies to the brother.",
                tags: ["boundary", "James"],
                summaryState: .ready,
                userTitle: "What James said about boundaries"
            ),
        ]
    }

    /// Apply seed data + onboarding completion. Idempotent — checks first
    /// whether entries already exist.
    @MainActor
    static func apply(modelContext: ModelContext, onboarding: OnboardingState) {
        guard isRequested else { return }
        if !onboarding.isCompleted {
            onboarding.markCompleted()
        }
        let existing = (try? modelContext.fetch(FetchDescriptor<Entry>())) ?? []
        guard existing.isEmpty else { return }
        for entry in entries() {
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }
}
