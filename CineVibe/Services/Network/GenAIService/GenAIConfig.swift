//
//  GenAIConfig.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Alamofire
import Foundation

enum GenAIConfig {
    static let baseURL = URL(string: "https://api.openai.com/v1")!

    static let decoder: any DataDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()

    static let defaultHeaders: HTTPHeaders = [
        .contentType("application/json"),
        .authorization(bearerToken: Auth.apiKey)
    ]

    static let model = "gpt-4o"

    static let systemPrompt = """
        You are a helpful movie recommendation assistant. \
        The user will describe a mood, vibe, or feeling. \
        Respond with only the name of one well-known movie that best matches that description. 
        DO NOT include quotes, explanations, dates, or any other information—respond with the movie name alone, without punctuation.
        """

    static let userPrompt = "I want to watch a movie that fits this vibe: "

    enum Auth {
        static let apiKey = """
            YOUR API KEY
            """
    }
}
