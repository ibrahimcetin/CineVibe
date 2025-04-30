//
//  TMDBServiceTests.swift
//  TMDBServiceTests
//
//  Created by İbrahim Çetin on 27.04.2025.
//

@testable import CineVibe
import Testing

struct TMDBServiceTests {
    @Test(
        "Test Movie Lists",
        arguments: [(MovieListType.topRated, 2), (.upcoming, 3), (.nowPlaying, 4), (.popular, 1)]
    )
    func testMovieList(of list: MovieListType, page: Int) async throws {
        let service = TMDBService()

        let publisher = service.fetchMovieList(of: list, page: page)
        let response = try await publisher.values.first { _ in true }

        let movies = try #require(response?.results)

        #expect(movies.isEmpty == false)
    }

    @Test(
        "Test Movie Search",
        arguments: [("Atonement", 1), ("The Godfather", 1), ("Django Unchained", 1)]
    )
    func testMovieSearch(query: String, page: Int) async throws {
        let service = TMDBService()

        let publisher = service.searchMovies(query: query, page: page)
        let response = try await publisher.values.first { _ in true }

        let movies = try #require(response?.results)

        #expect(movies.isEmpty == false)

        let firstResult = try #require(movies.first)
        #expect(firstResult.title.localizedStandardContains(query))
    }
}
