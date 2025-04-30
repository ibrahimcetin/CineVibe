//
//  GenAIServiceTests.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

@testable import CineVibe
import Testing

struct GenAIServiceTests {
    @Test("Test Generate")
    func testGenerate() async throws {
        let service = GenAIService()

        let publisher = service.generate(prompt: "Hello", model: "gpt-4o-mini", system: "You are a helpful assistant.")
        let response = try await publisher.values.first { _ in true }

        let message = try #require(response?.choices.first?.message)

        #expect(message.content.isEmpty == false)
        #expect(message.role == "assistant")
    }

    @Test("Test Movie Recommendation", arguments: [
        "Something that gives me chills and makes me think.",
        "Epic historical drama that feels like a journey.",
        "Summer romance with beautiful cinematography.",
        "A film that changed how you see life."
    ])
    func testMovieRecommendation(vibe: String) async throws {
        let service = GenAIService()

        let publisher = service.movieRecommendation(for: vibe)
        let response = try await publisher.values.first { _ in true }

        let movie = try #require(response)

        #expect(movie.isEmpty == false)

        print(vibe, " : ", movie)
    }
}
