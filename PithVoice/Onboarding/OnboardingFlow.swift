import AVFoundation
import Speech
import SwiftUI
import UserNotifications

/// Four-screen onboarding flow (FR-28). All four skippable after the first.
struct OnboardingFlow: View {
    @Bindable var state: OnboardingState
    @State private var step: Int = 0

    var body: some View {
        ZStack(alignment: .top) {
            DS.Color.background.ignoresSafeArea()
            VStack {
                progressDots
                Spacer()
                content
                Spacer()
                actions
            }
            .padding(.horizontal, DS.Space.l)
            .padding(.vertical, DS.Space.xl)
        }
    }

    private var progressDots: some View {
        HStack(spacing: DS.Space.xs) {
            ForEach(0..<4, id: \.self) { idx in
                Circle()
                    .fill(idx == step ? DS.Color.accent : DS.Color.hairline)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.top, DS.Space.m)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0: WhatIsPithScreen()
        case 1: WhatStaysHereScreen()
        case 2: PermissionsScreen()
        default: WeeklyDigestScreen()
        }
    }

    private var actions: some View {
        VStack(spacing: DS.Space.s) {
            Button(action: advance) {
                Text(primaryLabel)
                    .font(DS.Font.title)
                    .foregroundStyle(DS.Color.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Space.m)
                    .background(DS.Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                    .pithShadow(.s2)
            }
            .buttonStyle(.plain)
            if step >= 1 {
                Button("Skip") { state.markCompleted() }
                    .font(DS.Font.callout)
                    .foregroundStyle(DS.Color.textStone)
            }
        }
    }

    private var primaryLabel: String {
        switch step {
        case 0: "Continue"
        case 1: "Continue"
        case 2: "Allow"
        default: "Done"
        }
    }

    private func advance() {
        switch step {
        case 0, 1:
            step += 1
        case 2:
            Task {
                _ = await AVAudioApplication.requestRecordPermission()
                _ = await withCheckedContinuation { cont in
                    SFSpeechRecognizer.requestAuthorization { _ in cont.resume(returning: ()) }
                }
                step += 1
            }
        default:
            Task {
                try? await WeeklyDigestScheduler.schedule()
                state.markCompleted()
            }
        }
    }
}
