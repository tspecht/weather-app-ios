//
//  MockLocationProvider.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
@testable import Weather_App

class MockLocationProvider: LocationProvider {
    var fakeLocation: Location
    init(fakeLocation: Location) {
        self.fakeLocation = fakeLocation
    }

    func location() -> AnyPublisher<Weather_App.Location, Error> {
        return Just(fakeLocation)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
