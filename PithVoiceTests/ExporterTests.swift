import Foundation
@testable import PithVoice
import Testing

@Suite("Exporter")
@MainActor
struct ExporterTests {
    @Test("Exporter throws .noEntries when given empty array")
    func emptyEntriesThrows() async {
        await #expect(throws: ExportError.self) {
            _ = try await Exporter.makeArchive(entries: [])
        }
    }

    @Test("Exporter timestamp format is yyyy-MM-dd-HHmmss")
    func timestampFormat() {
        let fixed = DateComponents(
            calendar: .init(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 5,
            day: 19,
            hour: 14,
            minute: 30,
            second: 45
        ).date ?? Date()
        let result = Exporter.timestamp(fixed)
        #expect(result.count == 17)
        #expect(result.contains("2026-05-19"))
    }

    @Test("OnboardingState defaults to not completed")
    func onboardingDefault() {
        let defaults = UserDefaults(suiteName: "pith.test.onboarding.\(UUID().uuidString)")!
        defaults.removePersistentDomain(forName: defaults.dictionaryRepresentation().keys.first ?? "")
        let state = OnboardingState(defaults: defaults)
        #expect(state.isCompleted == false)
    }

    @Test("StartRecordingIntent bridges via UserDefaults")
    func intentBridge() {
        UserDefaults.standard.set(true, forKey: AppIntentBridge.pendingStartKey)
        #expect(AppIntentBridge.consumePendingStart() == true)
        // Should clear after consume.
        #expect(AppIntentBridge.consumePendingStart() == false)
    }
}
