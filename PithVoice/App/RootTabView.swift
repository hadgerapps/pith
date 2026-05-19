import SwiftUI

/// Root tab bar — Today · Threads · Settings (Flow 3 step 2).
struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
            ThreadsView()
                .tabItem {
                    Label("Threads", systemImage: "square.text.square")
                }
            SettingsPlaceholderView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(DS.Color.accent)
    }
}

/// Phase 5 placeholder — full Settings lands in Phase 7 (FR-30).
struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                DS.Color.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: DS.Space.m) {
                    Text("Settings")
                        .font(DS.Font.heroSerif)
                        .foregroundStyle(DS.Color.textInk)
                    Text("Subscription, export, and preferences arrive in the next build.")
                        .font(DS.Font.body)
                        .foregroundStyle(DS.Color.textStone)
                    Spacer()
                }
                .padding(.horizontal, DS.Space.l)
                .padding(.top, DS.Space.xl)
            }
        }
    }
}
