//
//  TMDBService.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 27.04.2025.
//

import Alamofire
import Combine
import Foundation

enum TMDBRequest: NetworkRequest {
    case movieList(type: MovieListType, page: Int)
    case searchMovies(query: String, page: Int)

    var path: String {
        switch self {
        case .movieList(type: let type, page: _):
            "/movie/" + type.rawValue
        case .searchMovies:
            "/search/movie"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: Parameters? {
        switch self {
        case .movieList(type: _, page: let page):
            ["page": page]
        case let .searchMovies(query: query, page: page):
            ["query": query, "page": page]
        }
    }

    var headers: HTTPHeaders? {
        TMDBConfig.defaultHeaders
    }
}

protocol TMDBServiceProtocol: NetworkServiceProtocol {
    func fetchMovieList(of type: MovieListType, page: Int) -> AnyPublisher<MovieResponse, AFError>

    func searchMovies(query: String, page: Int) -> AnyPublisher<MovieResponse, AFError>
}

final class TMDBService: TMDBServiceProtocol {
    let baseURL: URL = .init(string: "https://api.themoviedb.org/3")!
    let decoder: any DataDecoder = {
        let decoder = JSONDecoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return decoder
    }()

    func fetchMovieList(of type: MovieListType, page: Int) -> AnyPublisher<MovieResponse, AFError> {
        perform(TMDBRequest.movieList(type: type, page: page))
    }

    func searchMovies(query: String, page: Int) -> AnyPublisher<MovieResponse, AFError> {
        perform(TMDBRequest.searchMovies(query: query, page: page))
    }
}
