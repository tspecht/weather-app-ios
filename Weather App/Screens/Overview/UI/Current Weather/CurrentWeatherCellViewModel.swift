//
//  CurrentWeatherCellViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation

struct CurrentWeatherCellViewModel {
    let temperature: String
    let location: String
    let description: String
    let minTemperature: String?
    let maxTemperature: String?

    init(currentWeather: CurrentWeather, minTemperature: Float?, maxTemperature: Float?) {
        self.temperature = "\(Int(currentWeather.temperature.current))°"
        self.location = currentWeather.location.name
        self.description = currentWeather.description.description

        if let minTemperature = minTemperature {
            self.minTemperature = "L:\(Int(minTemperature))°"
        } else {
            self.minTemperature = nil
        }

        if let maxTemperature = maxTemperature {
            self.maxTemperature = "H:\(Int(maxTemperature))°"
        } else {
            self.maxTemperature = nil
        }
    }
}
