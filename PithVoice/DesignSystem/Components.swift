import SwiftUI

extension DS {
    /// Reusable view helpers built from tokens. New components land here
    /// only when used in ≥2 places. Single-use views live with their feature.
    enum Components {}
}

extension View {
    /// Apply the editorial card surface: paper background, md radius, s1 elevation.
    func pithCard() -> some View {
        background(DS.Color.surfacePaper)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .pithShadow(.s1)
    }

    /// Apply the quiet inline tag chip styling.
    func pithChip() -> some View {
        font(DS.Font.caption)
            .foregroundStyle(DS.Color.textStone)
            .padding(.horizontal, DS.Space.s)
            .padding(.vertical, DS.Space.xs)
            .background(DS.Color.chipTag)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
    }
}

extension DS.Components {
    /// Hairline divider, 1pt, hairline color.
    struct Hairline: View {
        var body: some View {
            Rectangle()
                .fill(DS.Color.hairline)
                .frame(height: DS.Stroke.hairline)
        }
    }
}
