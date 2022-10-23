//
//  OpenMeteoDataSourceTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation
import XCTest
@testable import Weather_App

class OpenMeteoDataSourceTests: XCTestCase {
    final class MockedData {
        public static let dailySuccessJSON: URL = Bundle(for: OpenMeteoDataSourceTests.self).url(forResource: "daily_success", withExtension: "json")!
    }

    private var mockNetworkClient = MockNetworkClient(requestAdapter: nil)
    private var dataSource: OpenMeteoDataSource!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dataSource = OpenMeteoDataSource(networkClient: mockNetworkClient)
    }

    override func tearDownWithError() throws {
        dataSource = nil
        mockNetworkClient.clearMocks()

        try super.tearDownWithError()
    }

    func testCurrentWeatherForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(Fakes.location.latitude)&longitude=\(Fakes.location.longitude)&hourly=temperature_2m,relativehumidity_2m,apparent_temperature,pressure_msl,cloudcover,windspeed_10m,winddirection_10m,windgusts_10m,precipitation,weathercode&current_weather=true&timezone=UTC&timeformat=unixtime"))
        mockNetworkClient.register(try! Data(contentsOf: MockedData.dailySuccessJSON), for: url)

        let currentWeather = try awaitPublisherResult(dataSource.currentWeather(for: Fakes.location))
        XCTAssertEqual(currentWeather, CurrentWeather(temperature: CurrentWeather.Temperature(current: 21.1, feelsLike: 18.6),
                                                      wind: Wind(speed: 2.5,
                                                                 gusts: 8.6,
                                                                 direction: 135),
                                                      clouds: Clouds(coverage: 0),
                                                      rain: nil,
                                                      description: WeatherDescription(icon: .clear, description: "Clear sky"),
                                                      humidity: 24,
                                                      pressure: 825,
                                                      location: Fakes.location,
                                                      time: Date(timeIntervalSince1970: 1666483200)))
    }

    func testForecastForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(Fakes.location.latitude)&longitude=\(Fakes.location.longitude)&hourly=temperature_2m,relativehumidity_2m,apparent_temperature,pressure_msl,cloudcover,windspeed_10m,winddirection_10m,windgusts_10m,precipitation,weathercode&current_weather=true&timezone=UTC&timeformat=unixtime"))
        mockNetworkClient.register(try! Data(contentsOf: MockedData.dailySuccessJSON), for: url)

        let forecast = try awaitPublisherResult(dataSource.dailyForecast(for: Fakes.location))

        let expectedForecasts = [
            // 10/23
            Fakes.dayForecast(for: Date(timeIntervalSince1970: 1666483200), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 21.1,
                                                                         max: 21.1,
                                                                         feelsLike: 18.6,
                                                                         average: 21.1),
                                wind: Wind(speed: 2.5,
                                           gusts: 8.6,
                                           direction: 135),
                                clouds: Clouds(coverage: 0),
                                rain: nil,
                                description: WeatherDescription(icon: .clear, description: "Clear sky"),
                                humidity: 24,
                                pressure: 825,
                                time: Date(timeIntervalSince1970: 1666483200)),
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 19.0,
                                                                         max: 19.0,
                                                                         feelsLike: 15.0,
                                                                         average: 19.0),
                                wind: Wind(speed: 7.2,
                                           gusts: 11.9,
                                           direction: 217),
                                clouds: Clouds(coverage: 0),
                                rain: nil,
                                description: WeatherDescription(icon: .clear, description: "Clear sky"),
                                humidity: 18,
                                pressure: 825,
                                time: Date(timeIntervalSince1970: 1666486800))
            ]),

            // 10/24
            Fakes.dayForecast(for: Date(timeIntervalSince1970: 1666569600), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 8.6,
                                                                         max: 8.6,
                                                                         feelsLike: 1.6,
                                                                         average: 8.6),
                                wind: Wind(speed: 22.6,
                                           gusts: 18.0,
                                           direction: 257),
                                clouds: Clouds(coverage: 96),
                                rain: nil,
                                description: WeatherDescription(icon: .partlyCloudy, description: "Partly cloudy"),
                                humidity: 53,
                                pressure: 822,
                                time: Date(timeIntervalSince1970: 1666569600)),
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 6.6,
                                                                         max: 6.6,
                                                                         feelsLike: 1.9,
                                                                         average: 6.6),
                                wind: Wind(speed: 13.0,
                                           gusts: 16.6,
                                           direction: 242),
                                clouds: Clouds(coverage: 66),
                                rain: Rain(hourly: 0.3),
                                description: WeatherDescription(icon: .partlyCloudy, description: "Partly cloudy"),
                                humidity: 62,
                                pressure: 823,
                                time: Date(timeIntervalSince1970: 1666573200))
            ])
        ]
        XCTAssertEqual(forecast, expectedForecasts)
    }
}
