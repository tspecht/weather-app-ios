//
//  Fakes.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation
@testable import Weather_App

struct Fakes {
    static let location = Location(name: "Test location", latitude: 123, longitude: 456)
    static let currentWeather = CurrentWeather(temperature: CurrentWeather.Temperature(current: 123,
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

    static func dayForecast(for date: Date = Date(), forecasts: [ForecastWeather]? = nil) -> DayForecast {
        DayForecast(date: date, forecasts: forecasts ?? [
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
                            time: date)
        ])
    }
}
