//
//  ForecastCellTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation
@testable import Weather_App
import XCTest

class ForecastCellTests: XCTestCase {
    func testConfigureWithViewModel() {
        let forecast = Fakes.dayForecast()
        let viewModel = ForecastCellViewModel(forecast: forecast, minTemperature: 0, maxTemperature: 100)
        let cell = ForecastCell(frame: .zero)
        cell.configure(with: viewModel)

        XCTAssertEqual(cell.dateLabel.text, viewModel.date)
        XCTAssertEqual(cell.minTemperatureLabel.text, viewModel.minTemperature)
        XCTAssertEqual(cell.maxTemperatureLabel.text, viewModel.maxTemperature)
        XCTAssertEqual(cell.iconImageView.image, viewModel.iconImage)
        XCTAssertEqual(cell.rangeView.start, viewModel.relativeTemperatureRange.start)
        XCTAssertEqual(cell.rangeView.end, viewModel.relativeTemperatureRange.end)
    }
}
