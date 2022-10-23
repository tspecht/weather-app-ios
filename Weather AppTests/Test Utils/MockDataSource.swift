//
//  MockDataSource.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/22/22.
//

import Alamofire
import Combine
@testable import Weather_App

class MockDataSource: DataSource {

    private let networkClient: NetworkClient

    var generatedCurrentWeather: [Location: CurrentWeather] = [:]
    var generatedDailyForecasts: [Location: [DayForecast]] = [:]

    required init(networkClient: Weather_App.NetworkClient) {
        self.networkClient = networkClient
    }

    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
        let weather = Fakes.currentWeather
        generatedCurrentWeather[location] = weather
        return Just(weather)
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        let dayForecasts = [
            Fakes.dayForecast(),
            Fakes.dayForecast(for: Date(timeIntervalSince1970: 4569))
        ]
        generatedDailyForecasts[location] = dayForecasts
        return Just(dayForecasts)
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
    }
}
