import AVFoundation
import Foundation
import Observation

/// Couples a `Recorder` and a `Transcriber` so a single mic tap drives both
/// the audio file write and live transcription. Owns the high-level "are we
/// capturing?" state surfaced to UI.
@MainActor
@Observable
final class CaptureSession {
    enum Phase: Equatable {
        case idle
        case starting
        case capturing(partial: String, since: Date)
        case finishing
        case finished(audioURL: URL, transcript: String, duration: TimeInterval, entryID: UUID)
        case failed(message: String)
    }

    private(set) var phase: Phase = .idle

    private let recorder = Recorder()
    private let transcriber = Transcriber()

    var isCapturing: Bool {
        if case .capturing = phase { return true }
        return false
    }

    var partial: String {
        if case .capturing(let text, _) = phase { return text }
        return ""
    }

    func start() async {
        phase = .starting
        do {
            try await transcriber.start()
            recorder.bufferTap = { [weak self] buffer, time in
                Task { @MainActor in
                    self?.transcriber.append(buffer: buffer, time: time)
                    self?.refreshPartial()
                }
            }
            try await recorder.start()
            phase = .capturing(partial: "", since: Date())
        } catch {
            phase = .failed(message: error.localizedDescription)
        }
    }

    private func refreshPartial() {
        guard case .capturing(_, let since) = phase else { return }
        phase = .capturing(partial: transcriber.partialText, since: since)
    }

    func stop() async {
        guard case .capturing(_, let since) = phase else { return }
        phase = .finishing
        transcriber.finish()
        await recorder.stop()

        try? await Task.sleep(nanoseconds: 300_000_000)

        let finalText = transcriber.finalText.isEmpty ? transcriber.partialText : transcriber.finalText
        let url = recorder.currentEntryAudioURL
        let duration = Date().timeIntervalSince(since)
        let id = recorder.currentEntryID
        phase = .finished(audioURL: url, transcript: finalText, duration: duration, entryID: id)
    }

    func reset() {
        transcriber.cancel()
        phase = .idle
    }
}
