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

    var generatedCurrentWeather: [Location: CurrentWeather] = [:]
    var generatedDailyForecasts: [Location: [DayForecast]] = [:]

    required init(session: Alamofire.Session, apiKey: String) {}

    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
        let weather = CurrentWeather(temperature: CurrentWeather.Temperature(current: 123,
                                                                             feelsLike: 123),
                                     wind: Wind(speed: 2,
                                                gusts: 3,
                                                direction: 4),
                                     clouds: Clouds(coverage: 100),
                                     rain: nil,
                                     description: WeatherDescription(icon: .clear, description: "clear skys"),
                                     humidity: 12,
                                     pressure: 1234,
                                     location: location,
                                     time: Date())
        generatedCurrentWeather[location] = weather
        return Just(weather)
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        let dayForecasts = [
            DayForecast(date: Date(), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 21.14,
                                                                         max: 23.64,
                                                                         feelsLike: 22.29,
                                                                         average: 21),
                                wind: Wind(speed: 3.88,
                                           gusts: 6.81,
                                           direction: 291),
                                clouds: Clouds(coverage: 54),
                                rain: nil,
                                description: WeatherDescription(icon: .clear, description: "clear skys"),
                                humidity: 9,
                                pressure: 1003,
                                time: Date(timeIntervalSince1970: 1666396800))
            ]),
            DayForecast(date: Date(timeIntervalSince1970: 4569), forecasts: [])
        ]
        generatedDailyForecasts[location] = dayForecasts
        return Just(dayForecasts)
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
    }
}
