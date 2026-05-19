import StoreKit
import SwiftUI

/// Hard paywall presented after the 2-entry allowance is used.
///
/// Layout per SPEC § Paywall:
/// - Headline: "Keep showing up for yourself."
/// - Plans in order: Annual (largest, recommended) · Lifetime · Weekly
/// - Subscribe / Unlock for life CTAs (no "Start free trial" copy)
/// - Restore Purchases · Privacy · Terms
/// - "What stays on your iPhone" reassurance band below the fold
enum PaywallSelection: Equatable {
    case annual
    case lifetime
    case weekly
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let catalog: ProductCatalog
    let controller: PaywallController
    let onPurchased: () -> Void

    @State private var selection: PaywallSelection = .annual
    @State private var purchaseInFlight = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                closeButton
                headline
                planList
                ctaButton
                disclosure
                reassurance
                footer
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.top, DS.Space.l)
            .padding(.bottom, DS.Space.xxl)
        }
        .background(DS.Color.background.ignoresSafeArea())
        .task {
            if catalog.weekly == nil { await catalog.load() }
        }
        .alert(
            "Couldn’t complete purchase",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(DS.Color.textStone)
                    .padding(DS.Space.s)
            }
            .accessibilityLabel("Close paywall")
        }
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Keep showing up for yourself.")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text("Unlimited entries. Themes. Read me back. All on this iPhone.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
    }

    private var planList: some View {
        VStack(spacing: DS.Space.m) {
            planCard(
                .annual,
                title: "Annual",
                subtitle: "Recommended",
                priceText: catalog.annual?.displayPrice ?? "$59.99",
                accent: true
            )
            planCard(
                .lifetime,
                title: "Lifetime",
                subtitle: "Never expires",
                priceText: catalog.lifetime?.displayPrice ?? "$99.99"
            )
            planCard(
                .weekly,
                title: "Weekly",
                subtitle: "Try weekly",
                priceText: catalog.weekly?.displayPrice ?? "$4.99"
            )
        }
    }

    @ViewBuilder
    private func planCard(
        _ selectionValue: PaywallSelection,
        title: String,
        subtitle: String,
        priceText: String,
        accent: Bool = false
    )
    -> some View {
        let isSelected = selection == selectionValue
        Button {
            selection = selectionValue
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DS.Space.s) {
                        Text(title)
                            .font(DS.Font.title)
                            .foregroundStyle(DS.Color.textInk)
                        if accent {
                            Text("Best value")
                                .pithChip()
                                .foregroundStyle(DS.Color.accent)
                        }
                    }
                    Text(subtitle)
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textStone)
                }
                Spacer()
                Text(priceText)
                    .font(DS.Font.title)
                    .foregroundStyle(DS.Color.textInk)
            }
            .padding(DS.Space.m)
            .background(DS.Color.surfacePaper)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .strokeBorder(
                        isSelected ? DS.Color.accent : DS.Color.hairline,
                        lineWidth: isSelected ? 2 : DS.Stroke.hairline
                    )
            }
            .pithShadow(.s1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(priceText), \(subtitle)")
    }

    private var ctaButton: some View {
        Button {
            Task { await purchaseSelected() }
        } label: {
            Text(ctaLabel)
                .font(DS.Font.title)
                .foregroundStyle(DS.Color.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.m)
                .background(DS.Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                .pithShadow(.s2)
        }
        .buttonStyle(.plain)
        .disabled(purchaseInFlight)
    }

    private var ctaLabel: String {
        switch selection {
        case .lifetime: "Unlock for life"
        default: "Subscribe"
        }
    }

    private var disclosure: some View {
        let text = "Subscriptions auto-renew until cancelled. " +
            "Cancel anytime in Settings → Apple ID. " +
            "Lifetime is a one-time purchase that never expires."
        return VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(text)
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.textStone)
        }
    }

    private var reassurance: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("What stays on your iPhone")
                .font(DS.Font.captionSmall)
                .textCase(.uppercase)
                .tracking(DS.Space.xs / 2)
                .foregroundStyle(DS.Color.textStone)
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                reassuranceRow("Audio, transcripts, summaries.")
                reassuranceRow("AI runs on Apple Intelligence, locally.")
                reassuranceRow("No accounts. No servers. No telemetry.")
            }
        }
        .padding(DS.Space.m)
        .background(DS.Color.surfaceSun)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
    }

    private func reassuranceRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.s) {
            Image(systemName: "lock.fill")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(DS.Color.accent)
            Text(text)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textInk)
        }
    }

    private var footer: some View {
        HStack(spacing: DS.Space.m) {
            Button("Restore purchases") {
                Task { await controller.restore() }
            }
            .font(DS.Font.callout)
            .foregroundStyle(DS.Color.textStone)
            Spacer()
            Link("Privacy", destination: URL(string: "https://hadgerapps.github.io/pith/privacy/")!)
                .font(DS.Font.callout)
                .foregroundStyle(DS.Color.textStone)
            Text("·").foregroundStyle(DS.Color.textMute)
            Link("Terms", destination: URL(string: "https://hadgerapps.github.io/pith/terms/")!)
                .font(DS.Font.callout)
                .foregroundStyle(DS.Color.textStone)
        }
    }

    private func purchaseSelected() async {
        guard let product = productForSelection() else { return }
        purchaseInFlight = true
        defer { purchaseInFlight = false }
        let result = await controller.purchase(product)
        switch result {
        case .succeeded:
            onPurchased()
            dismiss()
        case .cancelled, .pending:
            break
        case .failed(let message):
            errorMessage = message
        }
    }

    private func productForSelection() -> Product? {
        switch selection {
        case .annual: catalog.annual
        case .lifetime: catalog.lifetime
        case .weekly: catalog.weekly
        }
    }
}
