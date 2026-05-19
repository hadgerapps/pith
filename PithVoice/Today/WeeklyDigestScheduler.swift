import Foundation
import UserNotifications

/// Weekly Threads digest local notification (Flow 5).
///
/// Friday 8 AM by default. Opt-in via onboarding step 4 (FR-28.4). No
/// push — local only per SPEC § Push notifications.
enum WeeklyDigestScheduler {
    static let identifier = "pith.weekly-threads-digest"

    /// Schedule a weekly repeating notification for Friday at the given hour.
    /// Default: Friday 08:00 local time per SPEC Flow 5.
    static func schedule(weekday: Int = 6, hour: Int = 8) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound])
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your week, in 4 sentences."
        content.body = "Tap to open Threads."
        content.sound = .default

        var date = DateComponents()
        date.weekday = weekday
        date.hour = hour
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        try await center.add(request)
    }

    /// Cancel a previously scheduled digest.
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
