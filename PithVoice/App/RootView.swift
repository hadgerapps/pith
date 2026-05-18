import SwiftUI

/// Phase 1 placeholder Today screen.
///
/// Renders the Pith Voice wordmark in editorial serif on the Cream background,
/// using DesignSystem tokens exclusively (no raw colours, fonts, paddings, or
/// radii — verified by SwiftLint custom rules per SPEC § Implementation rules).
///
/// The full Today screen lands in Phase 4 (FR-17, FR-18, FR-19, FR-20).
struct RootView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            DS.Color.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DS.Space.s) {
                Text("Pith Voice")
                    .font(DS.Font.heroSerif)
                    .foregroundStyle(DS.Color.textInk)

                Text(Self.todayString)
                    .font(DS.Font.captionSmall)
                    .textCase(.uppercase)
                    .tracking(DS.Space.xs / 2)
                    .foregroundStyle(DS.Color.textStone)
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.top, DS.Space.xl)
        }
    }

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
