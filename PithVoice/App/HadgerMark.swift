import SwiftUI

/// Hadger studio mark. Per SPEC § Brand constraints and STUDIO.md §79-82:
/// Ember `#A8481C` is studio-exclusive and only allowed in this file and
/// `AboutView.swift` as an inline literal. The four-primitive shape
/// matches `Hadger_BRAND_README` so no asset-catalog dependency is needed.
struct HadgerMark: View {
    var size: CGFloat = 32
    var body: some View {
        ZStack {
            Circle()
                // Hadger brand color, AboutView-only per § Brand constraints
                    .fill(SwiftUI.Color(.sRGB, red: 0xA8 / 255, green: 0x48 / 255, blue: 0x1C / 255, opacity: 1))
            Text("H")
                .font(.system(size: size * 0.55, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Hadger studio")
    }
}

#Preview { HadgerMark(size: 48).padding() }
