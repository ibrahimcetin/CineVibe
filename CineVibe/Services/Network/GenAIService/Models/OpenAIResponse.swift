//
//  OpenAIResponse.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Foundation

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Date
    let model: String
    let choices: [Choice]
    let usage: Usage

    struct Choice: Codable {
        let index: Int
        let message: Message
        let finishReason: String
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}
