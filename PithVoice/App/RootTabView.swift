import SwiftUI

/// Root tab bar — Today · Threads · Settings (Flow 3 step 2). Gated on the
/// onboarding flag (FR-29) — first-launch users see OnboardingFlow until
/// they tap Done.
struct RootTabView: View {
    @State private var onboarding = OnboardingState()
    @State private var entitlements = EntitlementStore()
    @State private var catalog = ProductCatalog()
    @State private var paywallController: PaywallController?

    var body: some View {
        Group {
            if onboarding.isCompleted {
                tabs
            } else {
                OnboardingFlow(state: onboarding)
            }
        }
        .task {
            await entitlements.refreshFromStoreKit()
            await catalog.load()
            if paywallController == nil {
                paywallController = PaywallController(entitlements: entitlements, catalog: catalog)
            }
        }
    }

    @ViewBuilder
    private var tabs: some View {
        if let controller = paywallController {
            TabView {
                TodayView()
                    .tabItem { Label("Today", systemImage: "sun.max") }
                ThreadsView()
                    .tabItem { Label("Threads", systemImage: "square.text.square") }
                SettingsView(
                    onboarding: onboarding,
                    entitlements: entitlements,
                    controller: controller
                )
                .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .tint(DS.Color.accent)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Color.background.ignoresSafeArea())
        }
    }
}
