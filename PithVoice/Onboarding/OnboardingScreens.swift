import SwiftUI

struct WhatIsPithScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("A voice journal that stays on your iPhone.")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text("Tap to record. Speak. Stop. Pith Voice transcribes locally and writes a short summary.")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WhatStaysHereScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("What stays here.")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            VStack(alignment: .leading, spacing: DS.Space.m) {
                bullet("Apple SpeechAnalyzer transcribes on this device.")
                bullet("Apple Foundation Models writes the summary on this device.")
                bullet("Nothing leaves your iPhone unless you export.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.s) {
            Image(systemName: "lock.fill")
                .foregroundStyle(DS.Color.accent)
            Text(text)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textInk)
        }
    }
}

struct PermissionsScreen: View {
    private let copy = "Pith Voice needs the microphone (to record) and " +
        "Speech Recognition (to transcribe — locally). " +
        "Tap Continue and respond to both system prompts."

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("Two permissions.")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text(copy)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WeeklyDigestScreen: View {
    private let copy = "Once a week, on Friday, Pith Voice gathers the " +
        "strongest themes of the past seven days. Notifications are local. " +
        "You can turn this off in Settings any time."

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("Friday digest.")
                .font(DS.Font.heroSerif)
                .foregroundStyle(DS.Color.textInk)
            Text(copy)
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textStone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
