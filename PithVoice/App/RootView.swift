import SwiftUI

/// Wrapper so RootView can host a preview / smoke test that doesn't require
/// a full SwiftData stack. Production app uses `TodayView` directly via
/// PithVoiceApp's WindowGroup.
struct RootView: View {
    var body: some View {
        TodayView()
    }
}

#Preview("Light") { TodayView() }
#Preview("Dark") { TodayView().preferredColorScheme(.dark) }
