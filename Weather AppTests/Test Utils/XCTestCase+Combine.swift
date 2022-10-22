//
//  XCTestCase+Combine.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/20/22.
//

import Combine
import XCTest

extension XCTestCase {

    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Result<T.Output, Error> {
        return try awaitPublishers([publisher])[0]
    }

    func awaitPublishers<T: Publisher>(
        _ publishers: [T],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [Result<T.Output, Error>] {
        var cancellables = Set<AnyCancellable>()
        var results: [Result<T.Output, Error>?] = publishers.map { _ in nil }
        publishers.enumerated().forEach { index, publisher in
            // This time, we use Swift's Result type to keep track
            // of the result of our Combine pipeline:
            let expectation = self.expectation(description: "Awaiting publisher")

            publisher.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        results[index] = .failure(error)
                    case .finished:
                        break
                    }

                    expectation.fulfill()
                },
                receiveValue: { value in
                    results[index] = .success(value)
                }
            ).store(in: &cancellables)
        }

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellables.forEach { $0.cancel() }

        return try results.map {
            try XCTUnwrap(
                $0,
                "Awaited publisher did not produce any output",
                file: file,
                line: line
            )
        }
    }

    func awaitPublisherResult<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        return try awaitPublisher(publisher, timeout: timeout, file: file, line: line).get()
    }

    func awaitPublisherResults<T: Publisher>(
        _ publishers: [T],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [T.Output] {
        return try awaitPublishers(publishers, timeout: timeout, file: file, line: line).map { try $0.get() }
    }
}
