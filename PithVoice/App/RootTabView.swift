import SwiftUI

/// Root tab bar — Today · Threads · Settings (Flow 3 step 2). Gated on the
/// onboarding flag (FR-29) — first-launch users see OnboardingFlow until
/// they tap Done.
struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var onboarding = OnboardingState()
    @State private var entitlements = EntitlementStore()
    @State private var catalog = ProductCatalog()
    @State private var paywallController: PaywallController?
    @State private var selectedTab: Tab = UITestSeed.route == .threads ? .threads : .today

    enum Tab: Hashable { case today, threads, settings }

    var body: some View {
        Group {
            if UITestSeed.route == .paywall, let controller = paywallController {
                // App Store screenshot mode — render the paywall as a
                // full-screen view instead of a sheet. SwiftUI's .sheet
                // doesn't reliably render programmatically-triggered
                // content during simctl screenshot capture; direct
                // rendering is deterministic.
                PaywallView(
                    catalog: catalog,
                    controller: controller,
                    onPurchased: {}
                )
            } else if onboarding.isCompleted {
                tabs
            } else {
                OnboardingFlow(state: onboarding)
            }
        }
        .task {
            UITestSeed.apply(modelContext: modelContext, onboarding: onboarding)
            // Build the paywall controller eagerly so the tab bar can render
            // even before the StoreKit roundtrips complete. Catalog/
            // entitlements refresh runs after — `PaywallController` reads
            // them when actually presented, not at construction time.
            if paywallController == nil {
                paywallController = PaywallController(entitlements: entitlements, catalog: catalog)
            }
            await entitlements.refreshFromStoreKit()
            await catalog.load()
        }
    }

    @ViewBuilder
    private var tabs: some View {
        if let controller = paywallController {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(Tab.today)
                    .tabItem { Label("Today", systemImage: "sun.max") }
                ThreadsView()
                    .tag(Tab.threads)
                    .tabItem { Label("Threads", systemImage: "square.text.square") }
                SettingsView(
                    onboarding: onboarding,
                    entitlements: entitlements,
                    catalog: catalog,
                    controller: controller
                )
                .tag(Tab.settings)
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
