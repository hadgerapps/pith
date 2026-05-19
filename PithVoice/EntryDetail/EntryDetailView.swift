import AVFoundation
import SwiftData
import SwiftUI

/// Detail view for a single entry (FR-10, FR-14).
///
/// Shows full transcript + summary + tags, lets the user rename, edit
/// transcript (triggers re-distillation per FR-10), and delete (with
/// confirmation per FR-14).
struct EntryDetailView: View {
    @Bindable var entry: Entry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var distiller = Distiller()
    @State private var isEditingTranscript = false
    @State private var editingTranscript: String = ""
    @State private var editingTitle: String = ""
    @State private var showDeleteConfirm = false
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                titleBlock
                playbackControls
                summaryBlock
                tagsBlock
                transcriptBlock
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.vertical, DS.Space.xl)
        }
        .background(DS.Color.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Rename", systemImage: "pencil") { editingTitle = entry.userTitle ?? "" }
                    Button("Edit transcript", systemImage: "text.cursor") { startTranscriptEdit() }
                    if entry.summaryState != .ready {
                        Button("Re-run summary", systemImage: "arrow.clockwise") { Task { await redistill() } }
                    }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete this entry?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { performDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes the audio, transcript, and summary. There is no undo.")
        }
        .sheet(isPresented: $isEditingTranscript) {
            transcriptEditor
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(Self.dateFormatter.string(from: entry.createdAt))
                .font(DS.Font.captionSmall)
                .textCase(.uppercase)
                .tracking(DS.Space.xs / 2)
                .foregroundStyle(DS.Color.textStone)
            Text(entry.displayTitle)
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
        }
    }

    @ViewBuilder
    private var playbackControls: some View {
        if entry.audioURL != nil {
            HStack(spacing: DS.Space.m) {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(.largeTitle, design: .rounded))
                        .foregroundStyle(DS.Color.accent)
                }
                .accessibilityLabel(isPlaying ? "Pause playback" : "Play recording")
                Text(entry.durationDisplay)
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textStone)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var summaryBlock: some View {
        switch entry.summaryState {
        case .ready:
            if let summary = entry.summary, !summary.isEmpty {
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    Text("Summary")
                        .font(DS.Font.captionSmall)
                        .textCase(.uppercase)
                        .tracking(DS.Space.xs / 2)
                        .foregroundStyle(DS.Color.textStone)
                    Text(summary)
                        .font(DS.Font.body)
                        .foregroundStyle(DS.Color.textInk)
                }
            }
        case .pending:
            Text("Drawing the pith…")
                .font(DS.Font.body)
                .italic()
                .foregroundStyle(DS.Color.textMute)
        case .failed:
            Button {
                Task { await redistill() }
            } label: {
                Text("Summary unavailable — tap to retry.")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.danger)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var tagsBlock: some View {
        if !entry.tags.isEmpty {
            HStack(spacing: DS.Space.xs) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text(tag).pithChip()
                }
            }
        }
    }

    private var transcriptBlock: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Transcript")
                .font(DS.Font.captionSmall)
                .textCase(.uppercase)
                .tracking(DS.Space.xs / 2)
                .foregroundStyle(DS.Color.textStone)
            Text(entry.transcript.isEmpty ? "(no speech detected)" : entry.transcript)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textInk)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var transcriptEditor: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.m) {
                    TextField("Title", text: $editingTitle)
                        .font(DS.Font.titleSerif)
                    Divider()
                    TextEditor(text: $editingTranscript)
                        .font(DS.Font.body)
                        .frame(minHeight: DS.Space.xxxl * 4)
                }
                .padding(DS.Space.l)
            }
            .background(DS.Color.background.ignoresSafeArea())
            .navigationTitle("Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { isEditingTranscript = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveTranscriptEdit() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func startTranscriptEdit() {
        editingTranscript = entry.transcript
        editingTitle = entry.userTitle ?? ""
        isEditingTranscript = true
    }

    private func saveTranscriptEdit() {
        let textChanged = entry.transcript != editingTranscript
        entry.transcript = editingTranscript
        entry.userTitle = editingTitle.isEmpty ? nil : editingTitle
        if textChanged {
            entry.summaryState = .pending
            entry.summary = nil
            entry.tags = []
            try? modelContext.save()
            Task { await redistill() }
        } else {
            try? modelContext.save()
        }
        isEditingTranscript = false
    }

    private func redistill() async {
        entry.summaryState = .pending
        try? modelContext.save()
        guard distiller.isAvailable else {
            entry.summaryState = .failed
            try? modelContext.save()
            return
        }
        do {
            let result = try await distiller.distill(transcript: entry.transcript)
            entry.summary = result.summary
            entry.tags = result.tags
            entry.summaryState = .ready
        } catch {
            entry.summaryState = .failed
        }
        try? modelContext.save()
    }

    private func togglePlayback() {
        guard let url = entry.audioURL else { return }
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil {
                player = try? AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
            }
            player?.play()
            isPlaying = true
        }
    }

    private func performDelete() {
        EntryRepository.deleteAudioFile(for: entry)
        modelContext.delete(entry)
        try? modelContext.save()
        dismiss()
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
