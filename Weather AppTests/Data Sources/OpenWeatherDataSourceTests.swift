//
//  OpenWeatherDataSourceTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/20/22.
//

import Alamofire
import Foundation
import XCTest
@testable import Weather_App

class OpenWeatherDataSourceTests: XCTestCase {
    final class MockedData {
        public static let weatherSuccessJSON: URL = Bundle(for: OpenWeatherDataSourceTests.self).url(forResource: "weather_success", withExtension: "json")!
        public static let fiveDayForecastSuccessJSON: URL = Bundle(for: OpenWeatherDataSourceTests.self).url(forResource: "5d_forecast_success", withExtension: "json")!
    }

    private var mockNetworkClient = MockNetworkClient(requestAdapter: nil)
    private var dataSource: OpenWeatherDataSource!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dataSource = OpenWeatherDataSource(networkClient: mockNetworkClient)
    }

    override func tearDownWithError() throws {
        dataSource = nil
        mockNetworkClient.clearMocks()

        try super.tearDownWithError()
    }

    func testForecastForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(Fakes.location.latitude)&lon=\(Fakes.location.longitude)&units=metric&exclude=hourly,minutely"))

        mockNetworkClient.register(try! Data(contentsOf: MockedData.fiveDayForecastSuccessJSON), for: url)

        let forecast = try awaitPublisherResult(dataSource.dailyForecast(for: Fakes.location))

        // TODO: Need one more day in the test data to make sure the grouping works
        let expectedForecasts = [
            // 10/21
            Fakes.dayForecast(for: Date(timeIntervalSince1970: 1666332000), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 21.14,
                                                                         max: 23.64,
                                                                         feelsLike: 22.29,
                                                                         average: 23.64),
                                wind: Wind(speed: 3.88,
                                           gusts: 6.81,
                                           direction: 291),
                                clouds: Clouds(coverage: 54),
                                rain: nil,
                                description: WeatherDescription(icon: .brokenClouds,
                                                                description: "broken clouds"),
                                humidity: 9,
                                pressure: 1003,
                                time: Date(timeIntervalSince1970: 1666396800)),
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 16.86,
                                                                         max: 19.54,
                                                                         feelsLike: 17.92,
                                                                         average: 19.54),
                                wind: Wind(speed: 2.68,
                                           gusts: 4.67,
                                           direction: 267),
                                clouds: Clouds(coverage: 20),
                                rain: nil,
                                description: WeatherDescription(icon: .partlyCloudy,
                                                                description: "few clouds"),
                                humidity: 14,
                                pressure: 1003,
                                time: Date(timeIntervalSince1970: 1666407600))
            ]),

            // 10/26
            Fakes.dayForecast(for: Date(timeIntervalSince1970: 1666764000), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 6.53,
                                                                         max: 6.53,
                                                                         feelsLike: 4.82,
                                                                         average: 6.53),
                                wind: Wind(speed: 2.37,
                                           gusts: 4.16,
                                           direction: 139),
                                clouds: Clouds(coverage: 62),
                                rain: nil,
                                description: WeatherDescription(icon: .brokenClouds,
                                                                description: "broken clouds"),
                                humidity: 53,
                                pressure: 1012,
                                time: Date(timeIntervalSince1970: 1666785600)),
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 7.13,
                                                                         max: 7.13,
                                                                         feelsLike: 6.35,
                                                                         average: 7.13),
                                wind: Wind(speed: 1.52,
                                           gusts: 3.51,
                                           direction: 312),
                                clouds: Clouds(coverage: 26),
                                rain: nil,
                                description: WeatherDescription(icon: .scatteredClouds,
                                                                description: "scattered clouds"),
                                humidity: 49,
                                pressure: 1010,
                                time: Date(timeIntervalSince1970: 1666796400))
            ])
        ]
        XCTAssertEqual(forecast, expectedForecasts)
    }

    func testCurrentWeatherForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(Fakes.location.latitude)&lon=\(Fakes.location.longitude)&units=metric&exclude=hourly,minutely"))

        mockNetworkClient.register(try! Data(contentsOf: MockedData.weatherSuccessJSON), for: url)

        let currentWeather = try awaitPublisherResult(dataSource.currentWeather(for: Fakes.location))
        XCTAssertEqual(currentWeather, CurrentWeather(temperature: CurrentWeather.Temperature(current: 298.48,
                                                                                              feelsLike: 298.74),
                                                      wind: Wind(speed: 0.62,
                                                                 gusts: 1.18,
                                                                 direction: 349),
                                                      clouds: Clouds(coverage: 100),
                                                      rain: Rain(hourly: 3.16),
                                                      description: WeatherDescription(icon: .rain,
                                                                                      description: "moderate rain"),
                                                      humidity: 64,
                                                      pressure: 1015,
                                                      location: Fakes.location,
                                                      time: Date(timeIntervalSince1970: 1661870592)))
    }
}
