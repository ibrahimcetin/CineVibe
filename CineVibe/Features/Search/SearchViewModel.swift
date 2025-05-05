//
//  SearchViewModel.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Alamofire
import Combine
import Foundation

final class SearchViewModel {
    private let tmdbService: TMDBServiceProtocol
    private let genAIService: GenAIServiceProtocol

    private var cancellables: Set<AnyCancellable> = []

    private(set) var searchResult = CurrentValueSubject<SearchResultType?, Never>(nil)

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    init(tmdbService: TMDBServiceProtocol, genAIService: GenAIServiceProtocol) {
        self.tmdbService = tmdbService
        self.genAIService = genAIService
    }

    enum SearchResultType {
        case standard([Movie])
        case genAI([Movie])
    }

    func search(query: String, isGenAIEnabled: Bool) {
        guard isLoading == false else { return }

        isLoading = true
        cancellables.removeAll()

        if isGenAIEnabled {
            searchResult.send(.genAI([]))
            genAIService.movieRecommendation(for: query)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: handleCompletion) { [weak self] result in
                    self?.performTMDBSearch(query: result, page: 1)
                }
                .store(in: &cancellables)
        } else {
            searchResult.send(.standard([]))
            performTMDBSearch(query: query, page: 1)
        }
    }

    private func performTMDBSearch(query: String, page: Int) {
        tmdbService.searchMovies(query: query, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion) { [weak self] response in
                guard let self else { return }

                let foundMovies = response.results

                if let previousResults = searchResult.value {
                    switch previousResults {
                    case let .standard(movies):
                        searchResult.send(.standard(movies + foundMovies))
                    case .genAI:
                        // Only use the first search result for GenAI recommendations
                        let movies: [Movie] = if let movie = foundMovies.first {
                            [movie]
                        } else { [] }

                        searchResult.send(.genAI(movies))
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func handleCompletion(_ completion: Subscribers.Completion<some Any>) {
        isLoading = false

        if case let .failure(error) = completion {
            self.error = error
        }
    }
}
