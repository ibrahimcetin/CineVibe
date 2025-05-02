//
//  HomeViewModel.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 28.04.2025.
//

import Combine
import Foundation

final class HomeViewModel {
    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let tmdbService: TMDBServiceProtocol

    // MARK: - Published Properties

    @Published private(set) var nowPlayingMovies: [Movie] = []
    @Published private(set) var popularMovies: [Movie] = []
    @Published private(set) var topRatedMovies: [Movie] = []
    @Published private(set) var upcomingMovies: [Movie] = []
    @Published private(set) var error: Error?

    // MARK: - Initialization

    init(tmdbService: TMDBServiceProtocol) {
        self.tmdbService = tmdbService
    }

    // MARK: - Public Methods

    func fetchMovies() {
        // Cancel all previous requests
        cancellables.removeAll()

        // Fetch now playing movies
        tmdbService.fetchMovieList(of: .nowPlaying, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] response in
                self?.nowPlayingMovies = response.results
            }
            .store(in: &cancellables)

        // Fetch popular movies
        tmdbService.fetchMovieList(of: .popular, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] response in
                self?.popularMovies = response.results
            }
            .store(in: &cancellables)

        // Fetch top rated movies
        tmdbService.fetchMovieList(of: .topRated, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] response in
                self?.topRatedMovies = response.results
            }
            .store(in: &cancellables)

        // Fetch upcoming movies
        tmdbService.fetchMovieList(of: .upcoming, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] response in
                self?.upcomingMovies = response.results
            }
            .store(in: &cancellables)
    }

    private func handleCompletion(_ completion: Subscribers.Completion<some Any>) {
        if case let .failure(error) = completion {
            self.error = error
        }
    }
}
