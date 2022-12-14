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
        let feelsLike: Float
        let average: Float
    }

    let temperature: Temperature
    let wind: Wind
    let clouds: Clouds
    let rain: Rain?

    let description: WeatherDescription
    let humidity: Int
    let pressure: Int
    let time: Date
}

extension ForecastWeather: Identifiable {
    struct ObjectIdentifier: Hashable {
        let time: Date
    }

    var id: ObjectIdentifier {
        ObjectIdentifier(time: time)
    }
}
