import AVFoundation
import Foundation
import OSLog

private let recorderLogger = Logger(subsystem: "com.hadger.pith", category: "Recorder")

// MARK: - RecorderState

/// State machine the UI subscribes to.
enum RecorderState: Equatable {
    case idle
    case requestingPermission
    case recording(startedAt: Date)
    case finalising
    case finished(audioURL: URL, duration: TimeInterval)
    case failed(message: String)
}

// MARK: - RecorderError

enum RecorderError: Error, LocalizedError {
    case micPermissionDenied
    case audioSessionFailed(underlying: Error)
    case engineFailed(underlying: Error)
    case fileWriteFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .micPermissionDenied:
            "Pith Voice needs microphone access to record. Enable it in Settings → Pith Voice → Microphone."
        case .audioSessionFailed(let error):
            "Couldn't set up audio: \(error.localizedDescription)"
        case .engineFailed(let error):
            "Couldn't start the audio engine: \(error.localizedDescription)"
        case .fileWriteFailed(let error):
            "Couldn't write the recording: \(error.localizedDescription)"
        }
    }
}

// MARK: - Recorder

/// `Recorder` owns the `AVAudioEngine` + audio file write for a single entry.
/// 44.1 kHz mono AAC to `Documents/audio/<entry-id>.m4a` with
/// `NSFileProtectionComplete` set on the file (FR-1, FR-3, FR-13).
///
/// FR-4: 30-minute hard cap enforced by an internal Task.
///
/// `bufferTap` lets a `Transcriber` consume the same audio buffers for live
/// transcription in parallel with the file write — no second microphone tap.
@MainActor
final class Recorder {
    /// Maximum recording length in seconds (FR-4 — 30 min cap, battery/thermal).
    static let maxDuration: TimeInterval = 30 * 60

    private(set) var state: RecorderState = .idle

    /// Optional buffer sink the Transcriber attaches to. Single subscriber.
    var bufferTap: ((AVAudioPCMBuffer, AVAudioTime) -> Void)?

    private let audioEngine: AVAudioEngine
    private var audioFile: AVAudioFile?
    private var entryID = UUID()
    private var startDate: Date?
    private var capTask: Task<Void, Never>?

    init() {
        audioEngine = AVAudioEngine()
    }

    /// Returns the audio destination URL for a given entry ID.
    static func audioURL(for entryID: UUID) -> URL {
        documentsAudioDirectory().appendingPathComponent("\(entryID.uuidString).m4a")
    }

    static func documentsAudioDirectory() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audio = docs.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: audio,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.complete]
        )
        return audio
    }

    /// Request microphone permission. Returns true if granted.
    /// FR-5: standard iOS prompt with the message from Info.plist's
    /// `NSMicrophoneUsageDescription`.
    func requestMicPermission() async -> Bool {
        state = .requestingPermission
        return await AVAudioApplication.requestRecordPermission()
    }

    /// Begin recording. Throws if permission denied or audio engine fails.
    func start() async throws {
        guard await requestMicPermission() else {
            state = .failed(message: RecorderError.micPermissionDenied.localizedDescription)
            throw RecorderError.micPermissionDenied
        }

        entryID = UUID()
        let url = Recorder.audioURL(for: entryID)

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .spokenAudio,
                options: [.allowBluetooth, .defaultToSpeaker]
            )
            try session.setActive(true, options: [])
        } catch {
            recorderLogger.error("AudioSession setup failed: \(error.localizedDescription, privacy: .public)")
            throw RecorderError.audioSessionFailed(underlying: error)
        }

        let input = audioEngine.inputNode
        let hwFormat = input.outputFormat(forBus: 0)

        let aacSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44_100,
            AVEncoderBitRateKey: 64_000,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]

        do {
            audioFile = try AVAudioFile(
                forWriting: url,
                settings: aacSettings,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )
            try (url as NSURL).setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)
        } catch {
            recorderLogger.error("File create failed: \(error.localizedDescription, privacy: .public)")
            throw RecorderError.fileWriteFailed(underlying: error)
        }

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: hwFormat) { [weak self] buffer, time in
            guard let self else { return }
            try? audioFile?.write(from: buffer)
            bufferTap?(buffer, time)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            recorderLogger.error("Engine start failed: \(error.localizedDescription, privacy: .public)")
            throw RecorderError.engineFailed(underlying: error)
        }

        startDate = Date()
        state = .recording(startedAt: startDate ?? Date())

        capTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Recorder.maxDuration * 1_000_000_000))
            if let self, case .recording = self.state {
                await stop()
            }
        }
    }

    /// Stop recording. Finalises file, releases buffers (SPEC § Audio is never
    /// persisted means audio buffers — not the AAC file — are released; the file
    /// IS the persisted output for playback / export).
    func stop() async {
        capTask?.cancel()
        capTask = nil

        guard case .recording = state else { return }
        state = .finalising

        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()

        let url = Recorder.audioURL(for: entryID)
        let duration = startDate.map { Date().timeIntervalSince($0) } ?? 0
        audioFile = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])

        state = .finished(audioURL: url, duration: duration)
    }

    /// Current entry's expected audio URL (during or after recording).
    var currentEntryAudioURL: URL { Recorder.audioURL(for: entryID) }
    var currentEntryID: UUID { entryID }
}
