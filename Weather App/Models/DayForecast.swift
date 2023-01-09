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
    var minTemperature: Float? {
        forecasts.map { $0.temperature.min }.min()
    }

    var maxTemperature: Float? {
        forecasts.map { $0.temperature.max }.max()
    }

    var middleForecast: ForecastWeather {
        guard let middle = forecasts.middle else {
            fatalError("Expected non-empty list of forecasts!")
        }
        return middle
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
}

// MARK: - Comparable
extension DayForecast: Comparable {
    static func < (lhs: DayForecast, rhs: DayForecast) -> Bool {
        return lhs.date < rhs.date
    }
}
