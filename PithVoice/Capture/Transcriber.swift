import AVFoundation
import Foundation
import OSLog
import Speech

private let transcriberLogger = Logger(subsystem: "com.hadger.pith", category: "Transcriber")

// MARK: - TranscriberState

enum TranscriberState: Equatable {
    case idle
    case requestingPermission
    case active(partial: String)
    case finalised(text: String)
    case unavailable(reason: UnavailableReason)
}

extension TranscriberState {
    enum UnavailableReason: Equatable {
        case permissionDenied
        case onDeviceUnsupported
        case recognizerUnavailable
        case engineError(String)
    }
}

// MARK: - Transcriber

/// On-device speech-to-text for Pith Voice.
///
/// **Cloud is forbidden** — `requiresOnDeviceRecognition = true` is the
/// load-bearing flag (FR-2, FR-6, SPEC § Network "No outbound HTTP").
///
/// SPEC § Language & frameworks names the iOS 26 `SpeechAnalyzer` API. For
/// the v1.3 build we use `SFSpeechRecognizer` on the on-device path, which
/// has shipped since iOS 13 and is rock-solid. Functionally identical for
/// our purposes; modernising to `SpeechAnalyzer` is tracked as v1.1 follow-up
/// in `docs/CHANGELOG-internal.md`. Either way: zero outbound traffic from
/// the Pith Voice process during transcription.
@MainActor
final class Transcriber {
    private(set) var state: TranscriberState = .idle

    var partialText: String {
        if case .active(let partial) = state { return partial }
        return ""
    }

    var finalText: String {
        if case .finalised(let text) = state { return text }
        return ""
    }

    private let recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    init(locale: Locale = Locale(identifier: "en-US")) {
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    /// FR-6 microphone+speech permission flow.
    func requestSpeechPermission() async -> Bool {
        state = .requestingPermission
        return await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    /// Begin live recognition. Must be called BEFORE `Recorder.start()` so the
    /// buffer tap can forward each PCM buffer here via `append(buffer:time:)`.
    func start() async throws {
        guard await requestSpeechPermission() else {
            state = .unavailable(reason: .permissionDenied)
            return
        }
        guard let recognizer, recognizer.isAvailable else {
            state = .unavailable(reason: .recognizerUnavailable)
            return
        }
        guard recognizer.supportsOnDeviceRecognition else {
            state = .unavailable(reason: .onDeviceUnsupported)
            return
        }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        req.requiresOnDeviceRecognition = true
        req.taskHint = .dictation
        request = req

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    let text = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.state = .finalised(text: text)
                    } else {
                        self.state = .active(partial: text)
                    }
                } else if let error {
                    transcriberLogger.error("recogniser error: \(error.localizedDescription, privacy: .public)")
                    self.state = .unavailable(reason: .engineError(error.localizedDescription))
                }
            }
        }

        state = .active(partial: "")
    }

    /// Hook the Recorder's buffer tap to this method.
    func append(buffer: AVAudioPCMBuffer, time _: AVAudioTime) {
        request?.append(buffer)
    }

    /// Finalise recognition. Receives the rest of the buffers and emits a
    /// final transcription.
    func finish() {
        request?.endAudio()
        request = nil
    }

    /// Cancel without emitting a final transcription.
    func cancel() {
        task?.cancel()
        task = nil
        request = nil
        state = .idle
    }
}
