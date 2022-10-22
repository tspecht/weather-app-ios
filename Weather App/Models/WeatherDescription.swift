//
//  WeatherDescription.swift
//  Weather App
//
//  Created by Tim Specht on 10/22/22.
//

import Foundation

// TODO: Is this maybe a struct and includes some code for the description as well? There is int mappings that we cou
struct WeatherDescription: Equatable {
    enum Icon {
        case clear, partlyCloudy, scatteredClouds, brokenClouds, showers, rain, thunderstorm, snow, mist
    }

    let icon: Icon
    let description: String

    var iconImageAsset: ImageAsset {
        switch icon {
        case .clear:
            return Asset.clear
        case .partlyCloudy:
            return Asset.partlyCloudy
        case .scatteredClouds:
            return Asset.partlyCloudy
        case .brokenClouds:
            return Asset.partlyCloudy
        case .showers:
            return Asset.drizzle
        case .rain:
            return Asset.rain
        case .thunderstorm:
            return Asset.thunderstorms
        case .snow:
            return Asset.snow
        case .mist:
            return Asset.fog
        }
    }
}
