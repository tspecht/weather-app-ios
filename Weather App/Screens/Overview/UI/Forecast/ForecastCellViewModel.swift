//
//  ForecastCellViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation
import UIKit

private let dateFormatter = DateFormatter(format: "EE", timezone: TimeZone(secondsFromGMT: 0))

struct ForecastCellViewModel {
    let date: String
    let minTemperature: String
    let maxTemperature: String
    let relativeTemperatureRange: (start: Float, end: Float)
    let iconImage: UIImage

    init(forecast: DayForecast, minTemperature: Float, maxTemperature: Float) {
        let dayMinTemperature = forecast.minTemperature ?? 0
        let dayMaxTemperature = forecast.maxTemperature ?? 100

        self.maxTemperature = "\(Int(dayMaxTemperature))°"
        self.minTemperature = "\(Int(dayMinTemperature))°"
        self.relativeTemperatureRange = (start: (dayMinTemperature - minTemperature) / maxTemperature, end: dayMaxTemperature / maxTemperature)
        self.iconImage = forecast.middleForecast.description.iconImageAsset.image

        self.date = dateFormatter.string(from: forecast.date)
    }
}
