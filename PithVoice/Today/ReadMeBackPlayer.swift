import AVFoundation
import Foundation
import MediaPlayer
import Observation

/// Read me back playback engine — FR-25, FR-26, FR-27.
///
/// Wraps AVAudioPlayer plus MPNowPlayingInfoCenter so lock-screen + Control
/// Center show 'Pith Voice — N days ago' during playback.
@MainActor
@Observable
final class ReadMeBackPlayer {
    private(set) var isPlaying = false
    private(set) var currentEntry: Entry?
    private var player: AVAudioPlayer?
    private var observerTask: Task<Void, Never>?

    /// FR-27: explicit user-initiated only.
    func play(entry: Entry) {
        guard let url = entry.audioURL else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
            currentEntry = entry
            isPlaying = true
            updateNowPlayingInfo(entry: entry)
            startObserving()
        } catch {
            isPlaying = false
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        observerTask?.cancel()
        observerTask = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    /// FR-26: 15-second skip back / forward.
    func skipBack() {
        guard let player else { return }
        player.currentTime = max(0, player.currentTime - 15)
    }

    func skipForward() {
        guard let player else { return }
        player.currentTime = min(player.duration, player.currentTime + 15)
    }

    private func startObserving() {
        observerTask?.cancel()
        observerTask = Task { @MainActor [weak self] in
            while let self, isPlaying, let player {
                if !player.isPlaying, player.currentTime >= player.duration {
                    stop()
                    break
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    private func updateNowPlayingInfo(entry: Entry) {
        let daysAgo = max(0, Int(Date().timeIntervalSince(entry.createdAt) / 86_400))
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = entry.displayTitle
        info[MPMediaItemPropertyArtist] = "Pith Voice — \(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"
        info[MPMediaItemPropertyPlaybackDuration] = player?.duration ?? 0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
