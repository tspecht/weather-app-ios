//
//  Forecast.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation

// TODO: Not 100% happy with this name yet
struct Forecast: Equatable {

    let location: Location
    let current: CurrentWeather
    let daily: [ForecastWeather]
}
