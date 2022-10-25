//
//  LocationProvider.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine

protocol LocationProvider {
    func location() -> AnyPublisher<Location, Swift.Error>
}
