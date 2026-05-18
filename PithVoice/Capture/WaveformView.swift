import SwiftUI

/// Calm, organic waveform.
///
/// Per SPEC § Visual character: "The waveform during recording is the visual
/// hero — calm, organic, not 'audio-meter aggressive.'" Implemented as 24 bars
/// breathing on a slow sine modulation. With Reduce Motion (NFR-7) the bars
/// freeze in a static muted state.
struct WaveformView: View {
    let isRecording: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Double = 0

    private static let barCount = 24

    var body: some View {
        HStack(spacing: DS.Space.xs) {
            ForEach(0..<Self.barCount, id: \.self) { idx in
                Capsule(style: .continuous)
                    .fill(barColor)
                    .frame(width: DS.Space.xs, height: barHeight(idx: idx))
            }
        }
        .frame(height: DS.Space.xxxl)
        .accessibilityLabel(isRecording ? "Recording. Tap Stop to finish." : "Not recording.")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(DS.Motion.normal.repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private func barHeight(idx: Int) -> CGFloat {
        let mid = Double(Self.barCount) / 2.0
        let distance = abs(Double(idx) - mid) / mid
        let base: Double = isRecording ? (0.35 + 0.65 * (1 - distance)) : 0.20
        let breath: Double = (isRecording && !reduceMotion)
            ? 0.10 * sin((Double(idx) / Double(Self.barCount) * .pi * 2) + phase * .pi * 2)
            : 0
        return CGFloat((base + breath).clamped(to: 0.10...1.0)) * DS.Space.xxxl
    }

    private var barColor: SwiftUI.Color {
        isRecording ? DS.Color.accent : DS.Color.textMute
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview("Recording") { WaveformView(isRecording: true) }
#Preview("Idle") { WaveformView(isRecording: false) }
