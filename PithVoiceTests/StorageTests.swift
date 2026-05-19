import Foundation
@testable import PithVoice
import SwiftData
import Testing

@Suite("Storage")
@MainActor
struct StorageTests {
    @Test("Entry default summaryState is pending")
    func entryDefaults() {
        let entry = Entry()
        #expect(entry.summaryState == .pending)
        #expect(entry.transcript.isEmpty)
        #expect(entry.tags.isEmpty)
        #expect(entry.summary == nil)
    }

    @Test("Entry displayTitle falls back to first 8 words of transcript")
    func displayTitleFallback() {
        let entry = Entry(transcript: "Sat in the kitchen waiting for the kettle. Thought about Mom.")
        #expect(entry.displayTitle == "Sat in the kitchen waiting for the kettle.")
    }

    @Test("Entry displayTitle prefers userTitle if set")
    func displayTitlePrefersUser() {
        let entry = Entry(transcript: "Anything.", userTitle: "Morning")
        #expect(entry.displayTitle == "Morning")
    }

    @Test("Entry duration display formats minutes and seconds")
    func durationDisplay() {
        let short = Entry(duration: 42)
        #expect(short.durationDisplay == "42 sec")
        let long = Entry(duration: 4 * 60 + 13)
        #expect(long.durationDisplay == "4 min")
    }

    @Test("Entry summaryState round-trips through raw value")
    func summaryStateMutation() {
        let entry = Entry()
        entry.summaryState = .ready
        #expect(entry.summaryStateRaw == "ready")
        entry.summaryState = .failed
        #expect(entry.summaryStateRaw == "failed")
    }

    @Test("EntryRepository in-memory container creates")
    func containerCreates() throws {
        let container = try EntryRepository.makeContainer(inMemory: true)
        let ctx = ModelContext(container)
        let entry = Entry(transcript: "Hello")
        ctx.insert(entry)
        try ctx.save()
        let fetched = try ctx.fetch(FetchDescriptor<Entry>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.transcript == "Hello")
    }

    @Test("EntryRepository.shouldShowReadMeBack flips after 72h idle")
    func readMeBackThreshold() {
        let now = Date()
        let recent = now.addingTimeInterval(-10 * 60 * 60)
        let stale = now.addingTimeInterval(-73 * 60 * 60)
        #expect(EntryRepository.shouldShowReadMeBack(lastEntryAt: recent, now: now) == false)
        #expect(EntryRepository.shouldShowReadMeBack(lastEntryAt: stale, now: now) == true)
        #expect(EntryRepository.shouldShowReadMeBack(lastEntryAt: nil, now: now) == false)
    }

    @Test("EntrySearch matches transcript substring, case-insensitive")
    func searchTranscript() {
        let entry = Entry(transcript: "The hour before the meeting felt patient.")
        let hits = EntrySearch.filter([entry], query: "PATIENT")
        #expect(hits.count == 1)
    }

    @Test("EntrySearch matches tags")
    func searchTags() {
        let entry = Entry(transcript: "Anything.", tags: ["mom", "morning"])
        let hits = EntrySearch.filter([entry], query: "mom")
        let misses = EntrySearch.filter([entry], query: "evening")
        #expect(hits.count == 1)
        #expect(misses.isEmpty)
    }

    @Test("EntrySearch returns all when query is empty/whitespace")
    func searchEmpty() {
        let entries = [Entry(transcript: "a"), Entry(transcript: "b")]
        #expect(EntrySearch.filter(entries, query: "").count == 2)
        #expect(EntrySearch.filter(entries, query: "   ").count == 2)
    }
}
