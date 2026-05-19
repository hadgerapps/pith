import SwiftData
import SwiftUI

/// Today screen — primary surface (FR-17, FR-18, FR-19, FR-20).
///
/// - Serif wordmark + editorial date stamp.
/// - Record button (delegates to CaptureSession).
/// - Read me back affordance when the user has been idle ≥72h (FR-19).
/// - Chronological list of recent entries (most recent first).
/// - Pull-down search via FR-20 (text + tag match).
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]

    @State private var session = CaptureSession()
    @State private var distiller = Distiller()
    @State private var searchText: String = ""
    @State private var selectedEntry: Entry?
    @State private var entitlements = EntitlementStore()
    @State private var catalog = ProductCatalog()
    @State private var showPaywall = false
    @State private var paywallController: PaywallController?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                DS.Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.l) {
                        header
                        captureSurface
                        if EntryRepository.shouldShowReadMeBack(lastEntryAt: entries.first?.createdAt) {
                            readMeBackBanner
                        }
                        entryList
                    }
                    .padding(.horizontal, DS.Space.l)
                    .padding(.top, DS.Space.xl)
                    .padding(.bottom, DS.Space.xxl)
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search your journal"
            )
            .navigationDestination(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
            .sheet(isPresented: $showPaywall) {
                if let controller = paywallController {
                    PaywallView(
                        catalog: catalog,
                        controller: controller,
                        onPurchased: { showPaywall = false }
                    )
                    .interactiveDismissDisabled()
                }
            }
            .task {
                await entitlements.refreshFromStoreKit()
                await catalog.load()
                if paywallController == nil {
                    paywallController = PaywallController(
                        entitlements: entitlements,
                        catalog: catalog
                    )
                }
            }
        }
    }

    private var header: some View {
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
    }

    @ViewBuilder
    private var captureSurface: some View {
        VStack(spacing: DS.Space.m) {
            WaveformView(isRecording: session.isCapturing)
            switch session.phase {
            case .idle, .finished:
                Text(captureHint)
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textStone)
            case .starting, .finishing:
                Text("…")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textStone)
            case .capturing(let partial, _):
                Text(partial.isEmpty ? "Listening…" : partial)
                    .font(DS.Font.bodyItalic)
                    .foregroundStyle(DS.Color.textStone)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            case .failed(let message):
                Text(message)
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.danger)
                    .multilineTextAlignment(.center)
            }
            recordButton
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.m)
    }

    private var captureHint: String {
        entries.isEmpty ? "Tap to record your first entry." : "Tap to record."
    }

    private var recordButton: some View {
        Button(action: handleRecordTap) {
            Text(buttonLabel)
                .font(DS.Font.title)
                .foregroundStyle(DS.Color.background)
                .frame(width: DS.Space.xxxl + DS.Space.l, height: DS.Space.xxxl + DS.Space.l)
                .background(DS.Color.accent)
                .clipShape(Circle())
                .pithShadow(.s3)
        }
        .accessibilityLabel(session.isCapturing ? "Stop recording" : "Start recording")
    }

    private var buttonLabel: String {
        switch session.phase {
        case .capturing: "Stop"
        case .finishing: "…"
        default: "Rec"
        }
    }

    private var readMeBackBanner: some View {
        HStack(alignment: .center, spacing: DS.Space.m) {
            Image(systemName: "waveform")
                .foregroundStyle(DS.Color.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Read me back")
                    .font(DS.Font.title)
                    .foregroundStyle(DS.Color.textInk)
                Text(readMeBackCaption)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textStone)
            }
            Spacer()
        }
        .padding(DS.Space.m)
        .background(DS.Color.surfaceSun)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
        .onTapGesture {
            if let entry = entries.first {
                selectedEntry = entry
            }
        }
    }

    private var readMeBackCaption: String {
        guard let last = entries.first?.createdAt else { return "" }
        let days = Int(Date().timeIntervalSince(last) / 86_400)
        return days <= 0 ? "Replay yesterday." : "\(days) days ago"
    }

    @ViewBuilder
    private var entryList: some View {
        let visible = EntrySearch.filter(entries, query: searchText)
        if visible.isEmpty, !entries.isEmpty {
            Text("No entries match “\(searchText)”.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        } else {
            ForEach(visible) { entry in
                Button {
                    selectedEntry = entry
                } label: {
                    EntryCardView(entry: entry)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func handleRecordTap() {
        Task {
            switch session.phase {
            case .idle, .finished, .failed:
                if isPaywallBlocking() {
                    showPaywall = true
                    return
                }
                session.reset()
                await session.start()
            case .capturing:
                await session.stop()
                await persistFinishedCapture()
            case .starting, .finishing:
                break
            }
        }
    }

    private func isPaywallBlocking() -> Bool {
        guard let controller = paywallController else { return false }
        return controller.shouldPresentPaywall(currentEntryCount: entries.count)
    }

    private func persistFinishedCapture() async {
        guard case .finished(let audioURL, let transcript, let duration, let entryID) = session.phase else { return }
        let entry = Entry(
            id: entryID,
            createdAt: Date(),
            duration: duration,
            audioFilename: audioURL.lastPathComponent,
            transcript: transcript,
            summary: nil,
            tags: [],
            summaryState: .pending,
            userTitle: nil
        )
        modelContext.insert(entry)
        try? modelContext.save()

        guard distiller.isAvailable else {
            entry.summaryState = .failed
            try? modelContext.save()
            return
        }
        do {
            let distillation = try await distiller.distill(transcript: transcript)
            entry.summary = distillation.summary
            entry.tags = distillation.tags
            entry.summaryState = .ready
        } catch {
            entry.summaryState = .failed
        }
        try? modelContext.save()
    }

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}
