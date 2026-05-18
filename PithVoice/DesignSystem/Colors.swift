import SwiftUI

extension DS {
    /// Semantic color tokens for Pith Voice.
    ///
    /// All colors resolve from named entries in `Assets.xcassets/Colors.xcassets`
    /// at app build time. Light and dark variants are paired in each colorset.
    /// Hex literals live in the asset catalog JSON only — never in Swift code.
    ///
    /// The Hadger studio mark color **Ember `#A8481C`** is intentionally NOT
    /// included here. It is permitted only as an inline literal in
    /// `HadgerMark.swift` and `AboutView.swift` per SPEC § Brand constraints.
    enum Color {
        /// Primary app background. Light: warm cream `#FAFAF6`. Dark: warm ink `#1A1814`.
        static let background = SwiftUI.Color("bgCream", bundle: .main)

        /// Elevated card / sheet surface. Light: `#FFFFFF`. Dark: `#25221C`.
        static let surfacePaper = SwiftUI.Color("surfacePaper", bundle: .main)

        /// Subtle warm wash for emphasized rows and banners.
        static let surfaceSun = SwiftUI.Color("surfaceSun", bundle: .main)

        /// Primary text — warm near-black.
        static let textInk = SwiftUI.Color("textInk", bundle: .main)

        /// Secondary text — warm taupe.
        static let textStone = SwiftUI.Color("textStone", bundle: .main)

        /// Tertiary text — placeholder, disabled.
        static let textMute = SwiftUI.Color("textMute", bundle: .main)

        /// Subtle divider lines.
        static let hairline = SwiftUI.Color("hairline", bundle: .main)

        /// Primary accent — muted moss green, sufficiently far from Ember in hue.
        static let accent = SwiftUI.Color("accentMoss", bundle: .main)

        /// Accent on tinted surfaces — softer moss.
        static let accentSoft = SwiftUI.Color("accentMossSoft", bundle: .main)

        /// Quiet inline tag chip background.
        static let chipTag = SwiftUI.Color("chipTag", bundle: .main)

        /// Destructive action — deliberately rust-leaning to feel warm not clinical.
        static let danger = SwiftUI.Color("danger", bundle: .main)

        /// Success state — uses accent moss; calm, not celebratory.
        static let success = SwiftUI.Color("success", bundle: .main)
    }
}
