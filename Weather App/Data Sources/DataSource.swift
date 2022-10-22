//
//  DataSource.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation
import Combine

enum DataSourceError: Error {
    case networkError(underlyingError: Error)
}

protocol DataSource {
    init(networkClient: NetworkClient)
    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError>
    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError>
}
