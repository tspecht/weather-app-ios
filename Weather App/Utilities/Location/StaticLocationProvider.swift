//
//  StaticLocationProvider.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine

class StaticLocationProvider: LocationProvider {
    private let staticLocation: Location
    init(location: Location) {
        self.staticLocation = location
    }

    func location() -> AnyPublisher<Location,   Swift.Error> {
        return Just(staticLocation)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }
}
