//
//  OpenWeatherDataSourceTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation
import Mocker
import Alamofire
import XCTest
@testable import Weather_App

class OpenWeatherDataSourceTests: XCTestCase {

    final class MockedData {
        public static let weatherSuccessJSON: URL = Bundle(for: OpenWeatherDataSourceTests.self).url(forResource: "weather_success", withExtension: "json")!
        public static let fiveDayForecastSuccessJSON: URL = Bundle(for: OpenWeatherDataSourceTests.self).url(forResource: "5d_forecast_success", withExtension: "json")!
    }

    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        return configuration
    }()
    private let location = Location(name: "test123", latitude: 123.456, longitude: 123.456)
    private var dataSource: OpenWeatherDataSource!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dataSource = OpenWeatherDataSource(session: Alamofire.Session(configuration: configuration),
                                           apiKey: "test123")
    }

    override func tearDownWithError() throws {
        dataSource = nil
        Mocker.removeAll()

        try super.tearDownWithError()
    }

    func testForecastForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&appid=test123&units=metric&exclude=hourly,minutely"))

        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [
            .get: try! Data(contentsOf: MockedData.fiveDayForecastSuccessJSON)
        ])
        mock.register()

        let forecast = try awaitPublisherResult(dataSource.dailyForecast(for: location))

        // TODO: Need one more day in the test data to make sure the grouping works
        let expectedForecasts = [
            // 10/21
            DayForecast(date: Date(timeIntervalSince1970: 1666332000), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 21.14,
                                                                         max: 23.64,
                                                                         feelsLike: 22.29,
                                                                         average: 23.64),
                                wind: Wind(speed: 3.88,
                                           gusts: 6.81,
                                           direction: 291),
                                clouds: Clouds(coverage: 54),
                                rain: nil,
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
                                humidity: 14,
                                pressure: 1003,
                                time: Date(timeIntervalSince1970: 1666407600))
            ]),

            // 10/26
            DayForecast(date: Date(timeIntervalSince1970: 1666764000), forecasts: [
                ForecastWeather(temperature: ForecastWeather.Temperature(min: 6.53,
                                                                         max: 6.53,
                                                                         feelsLike: 4.82,
                                                                         average: 6.53),
                                wind: Wind(speed: 2.37,
                                           gusts: 4.16,
                                           direction: 139),
                                clouds: Clouds(coverage: 62),
                                rain: nil,
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
                                humidity: 49,
                                pressure: 1010,
                                time: Date(timeIntervalSince1970: 1666796400))
            ])
        ]
        XCTAssertEqual(forecast, expectedForecasts)
    }

    func testCurrentWeatherForLocationSuccess() throws {
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=test123&units=metric&exclude=hourly,minutely"))

        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [
            .get: try! Data(contentsOf: MockedData.weatherSuccessJSON)
        ])
        mock.register()

        let currentWeather = try awaitPublisherResult(dataSource.currentWeather(for: location))
        XCTAssertEqual(currentWeather, CurrentWeather(temperature: CurrentWeather.Temperature(current: 298.48,
                                                                                              feelsLike: 298.74),
                                                      wind: Wind(speed: 0.62,
                                                                 gusts: 1.18,
                                                                 direction: 349),
                                                      clouds: Clouds(coverage: 100),
                                                      rain: Rain(hourly: 3.16),
                                                      humidity: 64,
                                                      pressure: 1015,
                                                      location: location,
                                                      time: Date(timeIntervalSince1970: 1661870592)))
    }

    func testCurrentWeatherForLocationParseError() throws {
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=test123&units=metric&exclude=hourly,minutely"))

        let mockResponse = "{\"success\": false}"
        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [
            .get: mockResponse.data(using: .utf8)!
        ])
        mock.register()

        let result = try awaitPublisher(dataSource.currentWeather(for: location))
        XCTAssertNil(try? result.get())
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is DataSourceError)

            let dataSourceError = try XCTUnwrap(error as? DataSourceError)
            switch dataSourceError {
            case .networkError(let underlyingError):
                let afError = try XCTUnwrap(underlyingError as? AFError)
                switch afError {
                case .responseSerializationFailed:
                    // This is what we'd expect
                    break
                default:
                    XCTFail("Unexpected error \(afError)")
                }
            default:
                XCTFail("Unexpected error \(dataSourceError)")
            }
        default:
            XCTFail("Unexpected result \(result)")
        }
    }
}
