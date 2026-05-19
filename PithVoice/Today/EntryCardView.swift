import SwiftUI

/// Editorial entry card per FR-18. Date · duration · title · summary
/// (2-line truncation) · tags as inline chips.
struct EntryCardView: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Text(Self.dateFormatter.string(from: entry.createdAt))
                    .font(DS.Font.captionSmall)
                    .textCase(.uppercase)
                    .tracking(DS.Space.xs / 2)
                    .foregroundStyle(DS.Color.textStone)
                Spacer()
                Text(entry.durationDisplay)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textStone)
            }

            Text(entry.displayTitle)
                .font(DS.Font.titleSerif)
                .foregroundStyle(DS.Color.textInk)
                .lineLimit(2)

            switch entry.summaryState {
            case .ready:
                if let summary = entry.summary, !summary.isEmpty {
                    Text(summary)
                        .font(DS.Font.body)
                        .foregroundStyle(DS.Color.textStone)
                        .lineLimit(2)
                }
            case .pending:
                Text("Drawing the pith…")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textMute)
                    .italic()
            case .failed:
                Text("Summary unavailable — tap to retry.")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textMute)
            }

            if !entry.tags.isEmpty {
                HStack(spacing: DS.Space.xs) {
                    ForEach(entry.tags.prefix(4), id: \.self) { tag in
                        Text(tag).pithChip()
                    }
                }
                .padding(.top, DS.Space.xs)
            }
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
