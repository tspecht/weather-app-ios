//
//  StaticLocationProviderTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import XCTest
@testable import Weather_App

class StaticLocationProviderTests: XCTestCase {
    func testLocation() throws {
        let result = try awaitPublisherResult(StaticLocationProvider(location: Fakes.location).location())
        XCTAssertEqual(result, Fakes.location)
    }
}
