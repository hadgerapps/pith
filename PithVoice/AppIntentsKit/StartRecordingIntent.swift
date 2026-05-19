import AppIntents
import Foundation

/// Action Button intent — Flow 9.
///
/// Triggered by an iOS Shortcut bound to the iPhone 15 Pro+ Action Button.
/// Posts a Darwin notification the app observes to start recording at app
/// launch / wake.
struct StartRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Pith Voice recording"
    static var description = IntentDescription(
        "Begin a new Pith Voice journal entry. Audio and transcription stay on your iPhone."
    )

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: AppIntentBridge.pendingStartKey)
        return .result()
    }
}

/// Bridges the AppIntent into a UserDefaults flag the app reads on
/// foreground to auto-start recording without losing the user's tap context.
enum AppIntentBridge {
    static let pendingStartKey = "pith.appintent.pendingStartRecording"

    static func consumePendingStart() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: pendingStartKey) {
            defaults.set(false, forKey: pendingStartKey)
            return true
        }
        return false
    }
}

struct PithVoiceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartRecordingIntent(),
            phrases: [
                "Start \(.applicationName) recording",
                "Record in \(.applicationName)",
            ],
            shortTitle: "Start recording",
            systemImageName: "mic.fill"
        )
    }
}
