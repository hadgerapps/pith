import Foundation
import Observation

/// Persists whether the user has completed onboarding (FR-29).
@MainActor
@Observable
final class OnboardingState {
    enum Key {
        static let completed = "pith.onboarding.completed"
        static let weeklyDigest = "pith.onboarding.weeklyDigest"
    }

    private(set) var isCompleted: Bool

    init(defaults: UserDefaults = .standard) {
        isCompleted = defaults.bool(forKey: Key.completed)
    }

    func markCompleted() {
        UserDefaults.standard.set(true, forKey: Key.completed)
        isCompleted = true
    }

    /// Per FR-30 "Show onboarding again" debug affordance.
    func reset() {
        UserDefaults.standard.set(false, forKey: Key.completed)
        isCompleted = false
    }
}
