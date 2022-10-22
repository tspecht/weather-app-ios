//
//  DataSource.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Alamofire
import Foundation
import Combine

enum DataSourceError: Error {
    case cantConstructRequest
    case networkError(underlyingError: Error)
}

protocol DataSource {
    // TODO: This is an ugly dependency on Alamofire. WOuld be nice to have this behind an agnostic protocol
    init(session: Alamofire.Session, apiKey: String)
    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError>
    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError>
}
