//
//  TMDBConfig.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 28.04.2025.
//

import Alamofire
import Foundation

enum TMDBConfig {
    static let baseURL = URL(string: "https://api.themoviedb.org/3")!

    static let defaultHeaders: HTTPHeaders = [
        .accept("application/json"),
        .authorization(bearerToken: Auth.apiKey)
    ]

    enum Auth {
        static let apiKey = """
        YOU API KEY
        """
    }
}
