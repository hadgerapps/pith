import SwiftUI

/// Today screen — Phase 2 wiring.
///
/// Single Record button on a Cream background. Tap → mic + speech permission
/// prompts (FR-5, FR-6) → recording starts with live waveform (FR-1) and live
/// partial transcript (FR-2). Tap Stop → file finalised (FR-3), transcript
/// finalised. Full Today list / Threads / Settings tabs land in Phase 4+.
struct RootView: View {
    @State private var session = CaptureSession()

    var body: some View {
        ZStack(alignment: .topLeading) {
            DS.Color.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DS.Space.l) {
                header
                Spacer(minLength: DS.Space.xxl)
                centerContent
                Spacer(minLength: DS.Space.l)
                recordButton
                Spacer(minLength: DS.Space.l)
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.top, DS.Space.xl)
            .padding(.bottom, DS.Space.l)
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
    private var centerContent: some View {
        switch session.phase {
        case .idle:
            VStack(spacing: DS.Space.m) {
                WaveformView(isRecording: false)
                Text("Tap to record.")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textStone)
            }
            .frame(maxWidth: .infinity)
        case .starting, .finishing:
            VStack(spacing: DS.Space.m) {
                WaveformView(isRecording: false)
                Text("…")
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textStone)
            }
            .frame(maxWidth: .infinity)
        case .capturing(let partial, _):
            VStack(spacing: DS.Space.m) {
                WaveformView(isRecording: true)
                Text(partial.isEmpty ? "Listening…" : partial)
                    .font(DS.Font.bodyItalic)
                    .foregroundStyle(DS.Color.textStone)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(4)
            }
        case .finished(_, let transcript, _, _):
            VStack(alignment: .leading, spacing: DS.Space.s) {
                Text("Captured.")
                    .font(DS.Font.titleSerif)
                    .foregroundStyle(DS.Color.textInk)
                Text(transcript.isEmpty ? "(no speech detected)" : transcript)
                    .font(DS.Font.body)
                    .foregroundStyle(DS.Color.textInk)
                    .lineLimit(6)
            }
        case .failed(let message):
            Text(message)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.danger)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var recordButton: some View {
        HStack {
            Spacer()
            Button(action: handleRecordTap) {
                Text(buttonLabel)
                    .font(DS.Font.title)
                    .foregroundStyle(DS.Color.background)
                    .frame(width: DS.Space.xxxl + DS.Space.l, height: DS.Space.xxxl + DS.Space.l)
                    .background(DS.Color.accent)
                    .clipShape(Circle())
                    .pithShadow(.s3)
            }
            .accessibilityLabel(accessibilityLabel)
            Spacer()
        }
    }

    private var buttonLabel: String {
        switch session.phase {
        case .capturing: "Stop"
        case .finished: "New"
        default: "Rec"
        }
    }

    private var accessibilityLabel: String {
        switch session.phase {
        case .idle, .starting: "Start recording"
        case .capturing: "Stop recording"
        case .finishing: "Finalising"
        case .finished: "Start a new entry"
        case .failed: "Try again"
        }
    }

    private func handleRecordTap() {
        Task {
            switch session.phase {
            case .idle, .failed, .finished:
                session.reset()
                await session.start()
            case .capturing:
                await session.stop()
            case .starting, .finishing:
                break
            }
        }
    }

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}

#Preview("Light") { RootView() }
#Preview("Dark") { RootView().preferredColorScheme(.dark) }
