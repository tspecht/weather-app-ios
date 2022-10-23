//
//  ForecastCellViewModelTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import XCTest
@testable import Weather_App

class ForecastCellViewModelTests: XCTestCase {
    func testConfiguration() {
        let forecast = Fakes.dayForecast()
        let viewModel = ForecastCellViewModel(forecast: forecast, minTemperature: 0, maxTemperature: 100)
        XCTAssertEqual(viewModel.date, DateFormatter(format: "EE").string(from: forecast.date))
        XCTAssertEqual(viewModel.relativeTemperatureRange.start, 0.21139999)
        XCTAssertEqual(viewModel.relativeTemperatureRange.end, 0.2364)
        XCTAssertEqual(viewModel.iconImage, Asset.clear.image)
        XCTAssertEqual(viewModel.minTemperature, "21°")
        XCTAssertEqual(viewModel.maxTemperature, "23°")
    }
}
