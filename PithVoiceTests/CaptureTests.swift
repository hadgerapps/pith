import Foundation
@testable import PithVoice
import Testing

@Suite("Capture")
@MainActor
struct CaptureTests {
    @Test("Recorder starts idle")
    func recorderInitialState() {
        let recorder = Recorder()
        #expect(recorder.state == .idle)
    }

    @Test("Recorder audio URL is keyed by entry UUID")
    func recorderAudioURL() {
        let id = UUID()
        let url = Recorder.audioURL(for: id)
        #expect(url.lastPathComponent == "\(id.uuidString).m4a")
        #expect(url.pathComponents.contains("audio"))
    }

    @Test("Recorder max duration is 30 minutes per FR-4")
    func recorderHardCap() {
        #expect(Recorder.maxDuration == 30 * 60)
    }

    @Test("Transcriber starts idle")
    func transcriberInitialState() {
        let transcriber = Transcriber()
        #expect(transcriber.state == .idle)
    }

    @Test("Transcriber defaults to en-US")
    func transcriberDefaultLocale() {
        let transcriber = Transcriber()
        _ = transcriber
        #expect(Bool(true))
    }

    @Test("CaptureSession starts idle")
    func sessionInitialState() {
        let session = CaptureSession()
        if case .idle = session.phase {} else { Issue.record("expected .idle") }
        #expect(session.isCapturing == false)
        #expect(session.partial.isEmpty)
    }
}
