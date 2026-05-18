@testable import PithVoice
import Testing

@Suite("Phase 1 smoke")
@MainActor
struct SmokeTests {
    @Test("App target compiles and links")
    func appLinks() {
        let app = PithVoiceApp()
        _ = app.body
    }

    @Test("RootView renders without crashing")
    func rootViewRenders() {
        let view = RootView()
        _ = view.body
    }
}
