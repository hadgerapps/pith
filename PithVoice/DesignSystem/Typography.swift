import SwiftUI

extension DS {
    /// Typography tokens for Pith Voice.
    ///
    /// Two families: system serif (New York) for editorial hero/title surfaces,
    /// SF Pro Rounded for body, controls, and UI chrome. All tokens use
    /// `Font.system(_:design:weight:)` so Dynamic Type scales them per NFR-5.
    ///
    /// Italic body is reserved for live partial transcripts (FR-2) — the
    /// "thinking aloud" register the user sees while speaking.
    enum Font {
        /// Wordmark, main onboarding hero. Serif, semibold, ~34pt at .large.
        static let heroSerif = SwiftUI.Font.system(.largeTitle, design: .serif).weight(.semibold)

        /// Entry titles, primary section headers. Serif, medium, ~22pt at .large.
        static let titleSerif = SwiftUI.Font.system(.title2, design: .serif).weight(.medium)

        /// Sub-section headers, paywall plan name. Rounded, semibold, ~20pt.
        static let title = SwiftUI.Font.system(.title3, design: .rounded).weight(.semibold)

        /// Primary body — summary text, settings rows, paywall body. Rounded, regular, ~17pt.
        static let body = SwiftUI.Font.system(.body, design: .rounded).weight(.regular)

        /// Live partial transcript during recording (FR-2). Serif italic to read as voice-being-spoken.
        static let bodyItalic = SwiftUI.Font.system(.body, design: .serif).italic()

        /// Secondary actions, paywall fine print, restore-purchases link. Rounded, regular, ~16pt.
        static let callout = SwiftUI.Font.system(.callout, design: .rounded).weight(.regular)

        /// Metadata, tag chips, audio durations. Rounded, regular, ~13pt.
        static let caption = SwiftUI.Font.system(.caption, design: .rounded).weight(.regular)

        /// Date stamps and editorial timestamps. Rounded, medium, ~11pt — used sparingly.
        static let captionSmall = SwiftUI.Font.system(.caption2, design: .rounded).weight(.medium)
    }
}
