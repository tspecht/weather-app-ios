//
//  ForecastOverviewViewModelImplTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/21/22.
//

import Alamofire
import Combine
import XCTest
@testable import Weather_App

class ForecastOverviewViewModelImplTests: XCTestCase {

    class MockDataSource: DataSource {
        required init(session: Alamofire.Session, apiKey: String) {}

        func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
            Just(CurrentWeather(temperature: CurrentWeather.Temperature(current: 123,
                                                                        feelsLike: 123),
                                wind: Wind(speed: 2,
                                           gusts: 3,
                                           direction: 4),
                                clouds: Clouds(coverage: 100),
                                rain: nil,
                                humidity: 12,
                                pressure: 1234,
                                location: location,
                                time: Date())
            )
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
        }

        func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
            Just([
                DayForecast(date: Date(), forecasts: [])
            ])
            .setFailureType(to: DataSourceError.self)
            .eraseToAnyPublisher()
        }
    }

    let location = Location(name: "Test location", latitude: 123, longitude: 456)
    let session = Alamofire.Session()
    var viewModel: ForecastOverviewViewModelImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        viewModel = ForecastOverviewViewModelImpl(location: location, dataSource: MockDataSource(session: session, apiKey: "test123"))
    }

    func testLoadCurrentWeather() throws {
        let result = try awaitPublisherResult(viewModel.loadCurrentWeather())
    }
}
