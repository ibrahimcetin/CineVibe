//
//  IntegrationTests.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

@testable import CineVibe
import Testing

struct IntegrationTests {
    @Test("Test GenAI recommendation and TMDB search", arguments: [
        "I want to feel lost in another world.",
        "Rainy night, neon lights, and existential questions.",
        "A slow-burning mystery that keeps me guessing."
    ])
    func testGenAIandTMDB(vibe: String) async throws {
        let genAIService = GenAIService()
        let tmdbService = TMDBService()

        let genAIPublisher = genAIService.movieRecommendation(for: vibe)
        let genAIResponse = try await genAIPublisher.values.first { _ in true }

        let movieName: String = try #require(genAIResponse)

        // Movie name should never wraps in quotes
        #expect(movieName.contains("\"") == false)

        let tmdbPublisher = tmdbService.searchMovies(query: movieName, page: 1)
        let tmdbResponse = try await tmdbPublisher.values.first { _ in true }

        let movie = try #require(tmdbResponse?.results.first)

        #expect(movie.title == movieName)

        print(vibe, " : ", movieName, "==>", movie.title)
    }
}
