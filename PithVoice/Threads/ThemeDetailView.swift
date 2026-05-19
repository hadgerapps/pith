import SwiftUI

/// Theme drill-down — FR-22.
struct ThemeDetailView: View {
    let theme: Theme
    @State private var selectedEntry: Entry?

    var body: some View {
        ZStack(alignment: .topLeading) {
            DS.Color.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.l) {
                    VStack(alignment: .leading, spacing: DS.Space.s) {
                        Text(theme.label)
                            .font(DS.Font.heroSerif)
                            .foregroundStyle(DS.Color.textInk)
                        Text(theme.oneLineSummary)
                            .font(DS.Font.body)
                            .foregroundStyle(DS.Color.textStone)
                    }
                    ForEach(theme.entries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            excerpt(for: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DS.Space.l)
                .padding(.top, DS.Space.l)
                .padding(.bottom, DS.Space.xxl)
            }
        }
        .navigationDestination(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry)
        }
    }

    private func excerpt(for entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(Self.dateFormatter.string(from: entry.createdAt))
                .font(DS.Font.captionSmall)
                .textCase(.uppercase)
                .tracking(DS.Space.xs / 2)
                .foregroundStyle(DS.Color.textStone)
            Text(entry.summary ?? entry.transcript)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textInk)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .pithCard()
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
