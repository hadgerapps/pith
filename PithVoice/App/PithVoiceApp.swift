import SwiftData
import SwiftUI

@main
struct PithVoiceApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try EntryRepository.makeContainer()
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .modelContainer(modelContainer)
        }
    }
}
