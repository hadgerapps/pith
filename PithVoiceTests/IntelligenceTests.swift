import Foundation
@testable import PithVoice
import Testing

@Suite("Intelligence")
@MainActor
struct IntelligenceTests {
    @Test("System prompt forbids advice / reframing / questions per SPEC § Foundation Models")
    func systemPromptShape() {
        let prompt = Distiller.systemPrompt
        #expect(prompt.contains("do not give advice"))
        #expect(prompt.contains("past tense"))
    }

    @Test("User prompt embeds transcript and asks for EntryDistillation")
    func userPromptShape() {
        let prompt = Distiller.userPrompt(transcript: "I felt better after the walk.")
        #expect(prompt.contains("I felt better after the walk."))
        #expect(prompt.contains("EntryDistillation"))
    }

    @Test("EntryDistillation is Codable")
    func distillationCodable() throws {
        let dist = EntryDistillation(
            summary: "Talked about the conversation with Mom. Sat with it.",
            tags: ["mom", "morning"]
        )
        let data = try JSONEncoder().encode(dist)
        let decoded = try JSONDecoder().decode(EntryDistillation.self, from: data)
        #expect(decoded == dist)
    }

    @Test("SummaryState round-trips through raw value")
    func summaryStateRawValue() {
        #expect(SummaryState(rawValue: "pending") == .pending)
        #expect(SummaryState(rawValue: "ready") == .ready)
        #expect(SummaryState(rawValue: "failed") == .failed)
        #expect(SummaryState.ready.rawValue == "ready")
    }

    @Test("Distiller throws modelUnavailable when FM is not available")
    func distillerFailsClosed() async {
        let distiller = Distiller()
        if !distiller.isAvailable {
            await #expect(throws: DistillerError.self) {
                _ = try await distiller.distill(transcript: "anything")
            }
        }
    }
}
