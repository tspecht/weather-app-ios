//
//  Weather.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation

struct CurrentWeather: Equatable {
    struct Temperature: Equatable {
        let current: Float
        let feelsLike: Float
    }

    let temperature: Temperature
    let wind: Wind
    let clouds: Clouds
    let rain: Rain?

    let description: WeatherDescription
    let humidity: Int
    let pressure: Int
    let location: Location
    let time: Date
}
