//
//  ForecastWeather.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation
struct ForecastWeather: Equatable {
    struct Temperature: Equatable {
        let min: Float
        let max: Float
        let morning: Float
        let day: Float
        let evening: Float
        let night: Float
    }

    struct FeelsLike: Equatable {
        let morning: Float
        let day: Float
        let evening: Float
        let night: Float
    }

    let temperature: Temperature
    let feelsLike: FeelsLike
    let wind: Wind
    let clouds: Clouds
    let rain: Rain?

    let humidity: Int
    let pressure: Int
}
