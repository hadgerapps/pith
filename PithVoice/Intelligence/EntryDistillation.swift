import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - EntryDistillation

// Structured output of a single guided-generation run over one transcript.
// Produced by `Distiller` via FoundationModels (FR-7, FR-8).
//
// SPEC § Foundation Models prompt design:
// - `summary`: 2–3 plain sentences summarising what was said. Past tense.
//   No advice, no reframing, no encouragement.
// - `tags`: 2–4 subjects of thought; lowercase; one or two words each.
//   Examples: "boundary", "exhaustion", "Mom".

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct EntryDistillation: Codable, Equatable {
    @Guide(description: """
    Two to three plain sentences summarising what the speaker said. Past tense. \
    No advice, no reframing, no encouragement.
    """) let summary: String

    @Guide(description: """
    Two to four short thematic tags — subjects of thought, not categorical buckets. \
    Lowercase, one or two words each. Examples: 'boundary', 'exhaustion', 'Mom'.
    """) let tags: [String]
}
#else
/// Non-FM fallback so the code compiles on hosts without FoundationModels.
/// The actual app target is iOS 26+ where FoundationModels is always available.
struct EntryDistillation: Codable, Equatable {
    let summary: String
    let tags: [String]
}
#endif
