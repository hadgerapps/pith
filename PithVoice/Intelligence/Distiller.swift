import Foundation
import OSLog

#if canImport(FoundationModels)
import FoundationModels
#endif

private let distillerLogger = Logger(subsystem: "com.hadger.pith", category: "Distiller")

// MARK: - DistillerError

enum DistillerError: Error, LocalizedError {
    case modelUnavailable
    case generationFailed(underlying: Error)
    case contentRefused

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "Apple Intelligence isn't available on this device right now."
        case .generationFailed(let underlying):
            "Couldn't draw the pith: \(underlying.localizedDescription)"
        case .contentRefused:
            "Apple Intelligence declined to summarise this entry."
        }
    }
}

// MARK: - SummaryState

/// Mirrors `SwiftData` model's `summaryState` (FR-12).
enum SummaryState: String, Codable, Equatable {
    case pending
    case ready
    case failed
}

// MARK: - Distiller

/// Produces a structured `EntryDistillation` (summary + tags) for a transcript
/// via on-device Apple Intelligence (FR-7, FR-8, FR-9, FR-11).
///
/// `isAvailable` lets the UI render an "Apple Intelligence not active" state
/// (Open Question 8). Per SPEC § Open question 8 this becomes a first-launch
/// landing screen in Phase 7.
@MainActor
final class Distiller {
    /// True if Apple Intelligence is usable right now.
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available: return true
            default: return false
            }
        }
        #endif
        return false
    }

    /// System prompt — defines voice and constraints.
    static let systemPrompt = """
    You distill what a person said to themselves into a brief, respectful summary. \
    You do not give advice, ask questions, or reframe. You write past tense.
    """

    /// Build the user prompt for a transcript.
    static func userPrompt(transcript: String) -> String {
        "Here is the transcript:\n\n\(transcript)\n\nReturn an EntryDistillation."
    }

    /// Run guided generation. Throws `DistillerError` on unavailability,
    /// generation failure, or content refusal (FR-11 graceful failure).
    func distill(transcript: String) async throws -> EntryDistillation {
        guard isAvailable else {
            distillerLogger.error("FoundationModels unavailable")
            throw DistillerError.modelUnavailable
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let session = LanguageModelSession(instructions: Distiller.systemPrompt)
            do {
                let response = try await session.respond(
                    to: Distiller.userPrompt(transcript: transcript),
                    generating: EntryDistillation.self
                )
                return response.content
            } catch let error as LanguageModelSession.GenerationError {
                distillerLogger.error("FM generation error: \(error.localizedDescription, privacy: .public)")
                throw DistillerError.generationFailed(underlying: error)
            } catch {
                distillerLogger.error("FM unknown error: \(error.localizedDescription, privacy: .public)")
                throw DistillerError.generationFailed(underlying: error)
            }
        }
        #endif

        throw DistillerError.modelUnavailable
    }
}
