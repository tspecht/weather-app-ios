//
//  CurrentWeatherCellViewModelTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import XCTest
@testable import Weather_App

class CurrentWeatherCellViewModelTests: XCTestCase {
    func testConfiguration() {
        let viewModel = CurrentWeatherCellViewModel(currentWeather: Fakes.currentWeather, minTemperature: 1, maxTemperature: 23)
        XCTAssertEqual(viewModel.location, Fakes.location.name)
        XCTAssertEqual(viewModel.temperature, "123°")
        XCTAssertEqual(viewModel.description, "clear skys")
        XCTAssertEqual(viewModel.minTemperature, "L:1°")
        XCTAssertEqual(viewModel.maxTemperature, "H:23°")
    }
}
