import SwiftUI

extension DS {
    /// Motion tokens. All curves are ease-out — no bouncy spring on UI chrome.
    /// Per SPEC § Visual character: "Subtle motion: 200–300 ms ease-out for
    /// state changes; nothing bouncy; nothing that draws attention to itself."
    ///
    /// `Reduce Motion` (NFR-7) is honored by callers — use
    /// `@Environment(\.accessibilityReduceMotion)` to swap to opacity-only
    /// at `.fast` when on.
    enum Motion {
        /// State changes (toggles, hover) — 180 ms ease-out.
        static let fast = SwiftUI.Animation.easeOut(duration: 0.18)

        /// Tab switches, modal presentation — 280 ms ease-out.
        static let normal = SwiftUI.Animation.easeOut(duration: 0.28)

        /// Paywall reveal, drawing-the-pith shimmer fade-in — 450 ms ease-out.
        static let expressive = SwiftUI.Animation.easeOut(duration: 0.45)

        /// Soft spring for list reordering only. Never on hero elements.
        static let springSoft = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.85)
    }
}
