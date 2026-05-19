import SwiftData
import SwiftUI

/// Threads tab — FR-21, FR-22, FR-23.
///
/// Shows 3-4 strongest themes of the selected period. No charts, no streaks
/// — quiet typography per § Design vector.
struct ThreadsView: View {
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @State private var period: ThreadPeriod = .thisWeek
    @State private var selectedTheme: Theme?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                DS.Color.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.l) {
                        header
                        periodPicker
                        if themes.isEmpty {
                            emptyState
                        } else {
                            ForEach(themes) { theme in
                                Button {
                                    selectedTheme = theme
                                } label: {
                                    themeCard(theme)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, DS.Space.l)
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.xxl)
                }
            }
            .navigationDestination(item: $selectedTheme) { theme in
                ThemeDetailView(theme: theme)
            }
        }
    }

    private var themes: [Theme] {
        ThemeClusterer.themes(from: entries, period: period)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Threads")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text("The shape of what you've been carrying.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
    }

    private var periodPicker: some View {
        Picker("", selection: $period) {
            ForEach(ThreadPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Not enough entries yet.")
                .font(DS.Font.titleSerif)
                .foregroundStyle(DS.Color.textInk)
            Text("Themes emerge once a tag returns at least twice in the selected period.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
        .padding(.vertical, DS.Space.xl)
    }

    private func themeCard(_ theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Text(theme.label)
                    .font(DS.Font.titleSerif)
                    .foregroundStyle(DS.Color.textInk)
                Spacer()
                Text("\(theme.count)")
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textStone)
            }
            Text(theme.oneLineSummary)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .pithCard()
    }
}
