//
//  CurrentWeatherCellTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation
@testable import Weather_App
import XCTest

class CurrentWeatherCellTests: XCTestCase {
    func testConfigureWithViewModel() {
        let viewModel = CurrentWeatherCellViewModel(currentWeather: Fakes.currentWeather, minTemperature: 1, maxTemperature: 23)
        let cell = CurrentWeatherCell(frame: .zero)
        cell.configure(with: viewModel)

        XCTAssertEqual(cell.descriptionLabel.text, viewModel.description)
        XCTAssertEqual(cell.temperatureLabel.text, viewModel.temperature)
        XCTAssertEqual(cell.locationLabel.text, viewModel.location)
        XCTAssertEqual(cell.minTemperatureLabel.text, viewModel.minTemperature)
        XCTAssertEqual(cell.maxTemperatureLabel.text, viewModel.maxTemperature)
    }
}
