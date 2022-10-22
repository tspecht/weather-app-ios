//
//  MockNetworkClient.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/22/22.
//

import Combine
import Foundation
import XCTest
@testable import Weather_App

class MockNetworkClient: NetworkClient {

    enum MockingError: Swift.Error {
        case noMockResponseFound
    }

    private var mockResponses: [URL: Data] = [:]

    required init(requestAdapter: Weather_App.RequestAdapter? = nil) {}

    func getData<T>(_ url: URL, responseType: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        guard let mockData = mockResponses[url],
           let mockResponse = try? JSONDecoder().decode(T.self, from: mockData) else {
            XCTFail("No mock data found for \(url.absoluteString). Registered URLS: \(mockResponses.keys.map { $0.absoluteString })")
            return Fail(error: MockNetworkClient.MockingError.noMockResponseFound).eraseToAnyPublisher()
        }
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - API
extension MockNetworkClient {
    func register(_ mockResponse: Data, for url: URL) {
        mockResponses[url] = mockResponse
    }

    func clearMocks() {
        mockResponses.removeAll()
    }
}
