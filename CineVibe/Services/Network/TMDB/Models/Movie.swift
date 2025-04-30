//
//  Movie.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 28.04.2025.
//

import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let adult: Bool
    let backdropPath: String?
    let genreIDs: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: Date
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDs = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
}

enum MovieListType: String {
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming
}

// MARK: - Extensions

extension Movie {
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }

    var releaseDateFormatted: String {
        Movie.dateFormatter.string(from: releaseDate)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Sample Data

extension Movie {
    static let sampleMovies: [Movie] = [
        Movie(
            adult: false,
            backdropPath: "/628Dep6AxEtDxjZoGP78TsOxYbK.jpg",
            genreIDs: [28, 12, 878],
            id: 634_649,
            originalLanguage: "en",
            originalTitle: "Spider-Man: No Way Home",
            overview: """
            Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes\
            of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous,\
            forcing him to discover what it truly means to be Spider-Man.
            """,
            popularity: 6024.555,
            posterPath: "/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg",
            releaseDate: Date(timeIntervalSince1970: 1_639_526_400), // 2021-12-15
            title: "Spider-Man: No Way Home",
            video: false,
            voteAverage: 8.2,
            voteCount: 13954
        ),
        Movie(
            adult: false,
            backdropPath: "/iQFcwSGbZXMkeyKrxbPnwnRo5fl.jpg",
            genreIDs: [28, 12, 878],
            id: 634_649,
            originalLanguage: "en",
            originalTitle: "The Batman",
            overview: """
            In his second year of fighting crime, Batman uncovers corruption in Gotham City \
            that connects to his own family while facing a serial killer known as the Riddler.
            """,
            popularity: 4024.555,
            posterPath: "/74xTEgt7R36Fpooo50r9T25onhq.jpg",
            releaseDate: Date(timeIntervalSince1970: 1_646_092_800), // 2022-03-01
            title: "The Batman",
            video: false,
            voteAverage: 7.8,
            voteCount: 9954
        ),
        Movie(
            adult: false,
            backdropPath: "/5P8SmMzSNYikXpxil6BYzJ16611.jpg",
            genreIDs: [28, 12, 14, 878],
            id: 299_536,
            originalLanguage: "en",
            originalTitle: "Avengers: Infinity War",
            overview: """
            As the Avengers and their allies have continued to protect the world from threats too large for \
            any one hero to handle, a new danger has emerged from the cosmic shadows: Thanos.
            """,
            popularity: 3024.555,
            posterPath: "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg",
            releaseDate: Date(timeIntervalSince1970: 1_524_614_400), // 2018-04-25
            title: "Avengers: Infinity War",
            video: false,
            voteAverage: 8.3,
            voteCount: 25954
        )
    ]
}
