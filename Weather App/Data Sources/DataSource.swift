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
    init(session: Alamofire.Session, apiKey: String)
    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError>
    func forecast(for location: Location) -> AnyPublisher<Forecast, DataSourceError>
}
