//
//  DayForecast.swift
//  Weather App
//
//  Created by Tim Specht on 10/21/22.
//

import Foundation

struct DayForecast: Equatable {
    let date: Date
    let forecasts: [ForecastWeather]
}

// MARK: - Computed properties
extension DayForecast {
    var minimumTemperature: Float? {
        forecasts.map { $0.temperature.average }.min()
    }

    var maxTemperature: Float? {
        forecasts.map { $0.temperature.average }.max()
    }

    var middleForecast: ForecastWeather {
        guard let middle = forecasts.middle else {
            fatalError("Expected non-empty list of forecasts!")
        }
        return middle
    }
}

// MARK: - Comparable
extension DayForecast: Comparable {
    static func < (lhs: DayForecast, rhs: DayForecast) -> Bool {
        return lhs.date < rhs.date
    }
}
