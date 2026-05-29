import StoreKit
import SwiftData
import SwiftUI
import UIKit

/// Full Settings view (FR-30). Replaces the Phase 5 placeholder.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @Bindable var onboarding: OnboardingState
    let entitlements: EntitlementStore
    let catalog: ProductCatalog
    let controller: PaywallController

    @State private var weeklyDigestOn = true
    @State private var exportInProgress = false
    @State private var exportError: String?
    @State private var shareURL: URL?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                DS.Color.background.ignoresSafeArea()
                List {
                    subscriptionSection
                    journalSection
                    notificationsSection
                    aboutSection
                    debugSection
                }
                .scrollContentBackground(.hidden)
                .background(DS.Color.background)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(
                "Export failed",
                isPresented: Binding(
                    get: { exportError != nil },
                    set: { if !$0 { exportError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportError ?? "")
            }
            .sheet(item: Binding(
                get: { shareURL.map(ShareURL.init) },
                set: { _ in shareURL = nil }
            )) { share in
                ShareSheet(activityItems: [share.url])
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    catalog: catalog,
                    controller: controller,
                    onPurchased: { showPaywall = false }
                )
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            if let entitlement = entitlements.current, entitlement.isActive {
                row(label: "Status", value: entitlement.kind.rawValue.capitalized)
                if let expires = entitlement.expiresAt {
                    row(label: "Renews", value: Self.dateFormatter.string(from: expires))
                }
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    Link("Manage subscription", destination: url)
                        .foregroundStyle(DS.Color.accent)
                }
            } else {
                row(label: "Status", value: "Free")
                Button("View subscription options") {
                    showPaywall = true
                }
                .foregroundStyle(DS.Color.accent)
            }
            Button("Restore purchases") {
                Task { await controller.restore() }
            }
            .foregroundStyle(DS.Color.accent)
        }
    }

    private var journalSection: some View {
        Section("Journal") {
            row(label: "Entries", value: "\(entries.count)")
            Button {
                Task { await runExport() }
            } label: {
                HStack {
                    Text("Export your journal").foregroundStyle(DS.Color.accent)
                    if exportInProgress {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(exportInProgress || entries.isEmpty)
        }
    }

    private var notificationsSection: some View {
        Section("Weekly Threads digest") {
            Toggle(isOn: $weeklyDigestOn) {
                Text("Friday 8 AM").foregroundStyle(DS.Color.textInk)
            }
            .tint(DS.Color.accent)
            .onChange(of: weeklyDigestOn) { _, newValue in
                Task {
                    if newValue {
                        try? await WeeklyDigestScheduler.schedule()
                    } else {
                        WeeklyDigestScheduler.cancel()
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            if let privacy = URL(string: "https://hadgerapps.github.io/pith/privacy/") {
                Link("Privacy Policy", destination: privacy).foregroundStyle(DS.Color.accent)
            }
            if let terms = URL(string: "https://hadgerapps.github.io/pith/terms/") {
                Link("Terms of Use", destination: terms).foregroundStyle(DS.Color.accent)
            }
            if let support = URL(string: "mailto:hadger.support@gmail.com") {
                Link("Support", destination: support).foregroundStyle(DS.Color.accent)
            }
            NavigationLink {
                AboutView()
            } label: {
                Text("About Pith Voice").foregroundStyle(DS.Color.textInk)
            }
            row(label: "Version", value: Bundle.main.shortVersion + " (" + Bundle.main.buildVersion + ")")
        }
    }

    private var debugSection: some View {
        Section {
            Button("Show onboarding again") {
                onboarding.reset()
            }
            .foregroundStyle(DS.Color.textStone)
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(DS.Color.textInk)
            Spacer()
            Text(value).foregroundStyle(DS.Color.textStone)
        }
    }

    private func runExport() async {
        exportInProgress = true
        defer { exportInProgress = false }
        do {
            let url = try await Exporter.makeArchive(entries: entries)
            shareURL = url
        } catch {
            exportError = error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Helpers

private struct ShareURL: Identifiable {
    let url: URL
    var id: URL { url }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

private extension Bundle {
    var shortVersion: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0" }
    var buildVersion: String { infoDictionary?["CFBundleVersion"] as? String ?? "0" }
}
