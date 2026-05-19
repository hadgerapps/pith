import SwiftUI

/// About screen — FR-30 + § Brand constraints. Shows the Hadger mark,
/// version, "Made by Hadger" with tap-through to hadger.com, and the
/// list of Apple frameworks the app uses.
///
/// Ember `#A8481C` is used here as an inline literal in HadgerMark only.
/// No DesignSystem token for Ember exists by design.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                header
                whatItUsesSection
                madeByHadger
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.vertical, DS.Space.xl)
        }
        .background(DS.Color.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Pith Voice")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text("A journal you speak, kept on your iPhone.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
    }

    private var whatItUsesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Built on Apple frameworks")
                .font(DS.Font.captionSmall)
                .textCase(.uppercase)
                .tracking(DS.Space.xs / 2)
                .foregroundStyle(DS.Color.textStone)
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                bullet("SpeechAnalyzer — transcription on device")
                bullet("Apple Intelligence (Foundation Models) — summaries on device")
                bullet("SwiftData — storage on device")
                bullet("StoreKit 2 — subscription, the only outbound traffic")
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.s) {
            Image(systemName: "circle.fill")
                .foregroundStyle(DS.Color.accent)
                .font(.system(size: 4))
                .padding(.top, DS.Space.xs + 2)
            Text(text)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textInk)
        }
    }

    private var madeByHadger: some View {
        Link(destination: URL(string: "https://hadger.com")!) {
            HStack(spacing: DS.Space.m) {
                HadgerMark(size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Made by Hadger")
                        .font(DS.Font.title)
                        .foregroundStyle(DS.Color.textInk)
                    Text("hadger.com")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textStone)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(DS.Color.textStone)
            }
            .padding(DS.Space.m)
            .background(DS.Color.surfacePaper)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .pithShadow(.s1)
        }
        .buttonStyle(.plain)
    }
}
