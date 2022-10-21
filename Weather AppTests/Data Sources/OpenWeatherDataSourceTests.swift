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
        let url = try XCTUnwrap(URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=test123&units=metric&exclude=hourly,minutely"))

        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [
            .get: try! Data(contentsOf: MockedData.weatherSuccessJSON)
        ])
        mock.register()

        let forecast = try awaitPublisherResult(dataSource.dailyForecast(for: location))

        let expectedCurrentWeather = CurrentWeather(temperature: CurrentWeather.Temperature(current: 298.48,
                                                                                            feelsLike: 298.74),
                                                    wind: Wind(speed: 0.62,
                                                               gusts: 1.18,
                                                               direction: 349),
                                                    clouds: Clouds(coverage: 100),
                                                    rain: Rain(hourly: 3.16),
                                                    humidity: 64,
                                                    pressure: 1015,
                                                    location: location)
        XCTAssertEqual(forecast, Forecast(location: location,
                                          current: expectedCurrentWeather,
                                          daily: []))
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
                                                      location: location))
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
