//
//  DayForecastTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/21/22.
//

import XCTest
@testable import Weather_App

class DayForecastTests: XCTestCase {

    let dayForecast = DayForecast(date: Date(),
                                  forecasts: [
                                    ForecastWeather(temperature: ForecastWeather.Temperature(min: 21.14,
                                                                                             max: 23.64,
                                                                                             feelsLike: 22.29,
                                                                                             average: 21),
                                                    wind: Wind(speed: 3.88,
                                                               gusts: 6.81,
                                                               direction: 291),
                                                    clouds: Clouds(coverage: 54),
                                                    rain: nil,
                                                    humidity: 9,
                                                    pressure: 1003,
                                                    time: Date(timeIntervalSince1970: 1666396800)),
                                    ForecastWeather(temperature: ForecastWeather.Temperature(min: 12,
                                                                                             max: 21,
                                                                                             feelsLike: 22.29,
                                                                                             average: 24),
                                                    wind: Wind(speed: 3.88,
                                                               gusts: 6.81,
                                                               direction: 291),
                                                    clouds: Clouds(coverage: 54),
                                                    rain: nil,
                                                    humidity: 9,
                                                    pressure: 1003,
                                                    time: Date(timeIntervalSince1970: 1666396801))
                                  ])

    func testMinTemperature() {
        XCTAssertEqual(dayForecast.minimumTemperature, 21)
    }

    func testMaxTemperature() {
        XCTAssertEqual(dayForecast.maxTemperature, 24)
    }
}
