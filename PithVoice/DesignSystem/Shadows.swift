import SwiftUI

extension DS {
    /// Shadow elevation tokens.
    ///
    /// Pith Voice uses shadows sparingly — at most one elevation step
    /// per screen. Per SPEC § Design vector, the register is editorial
    /// and restrained, not photographic-depth.
    enum Shadow {
        /// No shadow — flat surface (default for body content).
        case s0
        /// Subtle card lift.
        case s1
        /// Modal sheet, paywall card.
        case s2
        /// Record button at rest — the only visual hero element.
        case s3

        var color: SwiftUI.Color {
            SwiftUI.Color(.sRGB, red: 0x1F / 255, green: 0x1B / 255, blue: 0x16 / 255, opacity: opacity)
        }

        var radius: CGFloat {
            switch self {
            case .s0: 0
            case .s1: 3
            case .s2: 12
            case .s3: 24
            }
        }

        var yOffset: CGFloat {
            switch self {
            case .s0: 0
            case .s1: 1
            case .s2: 4
            case .s3: 8
            }
        }

        var opacity: Double {
            switch self {
            case .s0: 0
            case .s1: 0.06
            case .s2: 0.08
            case .s3: 0.10
            }
        }
    }
}

extension View {
    /// Apply a Pith Voice elevation token. Respects Reduce Motion (NFR-7) and
    /// Reduce Transparency — both fall back to no shadow.
    func pithShadow(_ shadow: DS.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.yOffset)
    }
}
