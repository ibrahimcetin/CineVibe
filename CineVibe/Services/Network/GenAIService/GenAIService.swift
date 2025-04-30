//
//  GenAIService.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 28.04.2025.
//

import Alamofire
import Combine
import Foundation

enum GenAIRequest: NetworkRequest {
    case generate(prompt: String, model: String, system: String)

    var path: String {
        switch self {
        case .generate:
            "/chat/completions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .generate:
            .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .generate(prompt: prompt, model: model, system: system):
            [
                "model": model,
                "messages": [
                    [
                        "role": "system",
                        "content": system
                    ],
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ]
            ]
        }
    }

    var headers: HTTPHeaders? {
        GenAIConfig.defaultHeaders
    }
}

protocol GenAIServiceProtocol: NetworkServiceProtocol {
    func generate(prompt: String, model: String, system: String) -> AnyPublisher<OpenAIResponse, AFError>
}

final class GenAIService: GenAIServiceProtocol {
    let baseURL = GenAIConfig.baseURL
    let decoder = GenAIConfig.decoder

    func generate(prompt: String, model: String, system: String) -> AnyPublisher<OpenAIResponse, AFError> {
        perform(GenAIRequest.generate(prompt: prompt, model: model, system: system))
    }

    func movieRecommendation(for vibe: String) -> AnyPublisher<String, AFError> {
        generate(prompt: GenAIConfig.userPrompt + vibe, model: GenAIConfig.model, system: GenAIConfig.systemPrompt)
            .map { $0.choices.first?.message.content ?? "" }
            .eraseToAnyPublisher()
    }
}
