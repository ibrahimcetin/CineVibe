//
//  NetworkService.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 27.04.2025.
//

import Alamofire
import Combine
import Foundation

// MARK: - NetworkRequest

protocol NetworkRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
}

// MARK: - Network Service Protocol

protocol NetworkServiceProtocol {
    var baseURL: URL { get }
    var decoder: any DataDecoder { get }

    func perform<T: Decodable>(_ request: NetworkRequest) -> AnyPublisher<T, AFError>
}

extension NetworkServiceProtocol {
    func perform<T: Decodable>(_ request: NetworkRequest) -> AnyPublisher<T, AFError> {
        let url = baseURL.appendingPathComponent(request.path)

        return AF.request(
            url,
            method: request.method,
            parameters: request.parameters,
            headers: request.headers
        )
        .validate()
        .publishDecodable(type: T.self, decoder: decoder)
        .value()
    }
}
