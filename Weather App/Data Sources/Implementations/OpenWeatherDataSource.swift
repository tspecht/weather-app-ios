//
//  OpenWeather.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation
import Combine
import Alamofire

private struct OpenWeatherV3Response: Codable {
    struct CurrentWeather: Codable {
        enum CodingKeys: String, CodingKey {
            case temp, feelsLike = "feels_like", pressure, humidity, windSpeed = "wind_speed", windGust = "wind_gust", windDeg = "wind_deg", clouds, rain
        }

        let temp: Float
        let feelsLike: Float
        let pressure: Int
        let humidity: Int
        let windSpeed: Float
        let windGust: Float
        let windDeg: Int
        let clouds: Float
        let rain: Rain?
    }

    struct DailyWeather: Codable {
        enum CodingKeys: String, CodingKey {
            case temp, feelsLike = "feels_like", pressure, humidity, windSpeed = "wind_speed", windGust = "wind_gust", windDeg = "wind_deg", clouds, rain
        }

        struct Temp: Codable {
            let morn: Float
            let day: Float
            let eve: Float
            let night: Float
            let min: Float
            let max: Float
        }

        struct FeelsLike: Codable {
            let morn: Float
            let day: Float
            let eve: Float
            let night: Float
        }

        let temp: Temp
        let feelsLike: FeelsLike
        let windSpeed: Float
        let windGust: Float
        let windDeg: Int
        let pressure: Int
        let humidity: Int
        let clouds: Float
        let rain: Rain?
    }

    struct Rain: Codable {
        enum CodingKeys: String, CodingKey {
            case perHour = "1h"
        }
        let perHour: Float
    }

    struct Clouds: Codable {
        let all: Float
    }

    let current: OpenWeatherV3Response.CurrentWeather
    let daily: [OpenWeatherV3Response.DailyWeather]
}

private struct OpenWeatherCurrentWeatherResponse: Codable {
    struct Main: Codable {
        enum CodingKeys: String, CodingKey {
            case temp, feelsLike = "feels_like", humidity, pressure
        }

        let temp: Float
        let feelsLike: Float
        let humidity: Int
        let pressure: Int
    }

    struct Wind: Codable {
        let speed: Float
        let gust: Float?
        let deg: Int
    }

    struct Rain: Codable {
        enum CodingKeys: String, CodingKey {
            case perHour = "1h"
        }
        let perHour: Float
    }

    struct Clouds: Codable {
        let all: Float
    }

    let main: Main
    let wind: Wind
    let rain: Rain?
    let clouds: Clouds
    let dt: Double
}

class OpenWeatherDataSource: DataSource {
    private let apiKey: String
    private let session: Alamofire.Session

    required init(session: Alamofire.Session, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func forecast(for location: Location) -> AnyPublisher<Forecast, DataSourceError> {
        // TODO: Long-term we want to either call two APIs and merge them into one forecast, call v3 or just change it all together. For now, we simply return an empty list for the daily forecast
        return currentWeather(for: location)
            .map { Forecast(location: location, current: $0, daily: []) }
            .eraseToAnyPublisher()
//        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
//        guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric&exclude=hourly,minutely") else {
//            return Fail(error: .cantConstructRequest).eraseToAnyPublisher()
//        }
//        return session.request(url, method: .get)
//            .validate()
//            .publishDecodable(type: OpenWeatherV3Response.self)
//            .value()
//            .mapError { error in
//                return DataSourceError.networkError(underlyingError: error)
//            }
//            .map { result in
//                // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
//                let currentRain: Rain?
//                if let openWeatherRain = result.current.rain {
//                    currentRain = Rain(hourly: openWeatherRain.perHour)
//                } else {
//                    currentRain = nil
//                }
//
//                let currentWeather = CurrentWeather(temperature: CurrentWeather.Temperature(current: result.current.temp,
//                                                                              feelsLike: result.current.feelsLike),
//                                             wind: Wind(speed: result.current.windSpeed,
//                                                                gusts: result.current.windGust,
//                                                                direction: result.current.windDeg),
//                                             clouds: Clouds(coverage: result.current.clouds),
//                                             rain: currentRain,
//                                             humidity: result.current.humidity,
//                                             pressure: result.current.pressure)
//                let dailyWeather = result.daily.map {
//                    // TODO: This isn't a great abstraction yet as it loses precision for the different temperature values
//                    let forecastRain: Rain?
//                    if let openWeatherRain = $0.rain {
//                        forecastRain = Rain(hourly: openWeatherRain.perHour)
//                    } else {
//                        forecastRain = nil
//                    }
//                    return ForecastWeather(temperature: ForecastWeather.Temperature(min: $0.temp.min,
//                                                                                    max: $0.temp.max,
//                                                                                    morning: $0.temp.morn,
//                                                                                    day: $0.temp.day,
//                                                                                    evening: $0.temp.eve,
//                                                                                    night: $0.temp.night),
//                                           feelsLike: ForecastWeather.FeelsLike(morning: $0.feelsLike.morn,
//                                                                                day: $0.feelsLike.day,
//                                                                                evening: $0.feelsLike.eve,
//                                                                                night: $0.feelsLike.night),
//                                           wind: Wind(speed: $0.windSpeed,
//                                                      gusts: $0.windGust,
//                                                      direction: $0.windDeg),
//                                           clouds: Clouds(coverage: $0.clouds),
//                                           rain: forecastRain,
//                                           humidity: $0.humidity,
//                                           pressure: $0.pressure)
//
//                }
//                return Forecast(location: location,
//                                current: currentWeather,
//                                daily: dailyWeather)
//            }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
    }

    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric&exclude=hourly,minutely") else {
            return Fail(error: .cantConstructRequest).eraseToAnyPublisher()
        }
        return session.request(url, method: .get)
            .validate()
            .publishDecodable(type: OpenWeatherCurrentWeatherResponse.self)
            .value()
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .map { result in
                // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
                let currentRain: Rain?
                if let openWeatherRain = result.rain {
                    currentRain = Rain(hourly: openWeatherRain.perHour)
                } else {
                    currentRain = nil
                }

                return CurrentWeather(temperature: CurrentWeather.Temperature(current: result.main.temp,
                                                                              feelsLike: result.main.feelsLike),
                                      wind: Wind(speed: result.wind.speed,
                                                 gusts: result.wind.gust,
                                                 direction: result.wind.deg),
                                      clouds: Clouds(coverage: result.clouds.all),
                                      rain: currentRain,
                                      humidity: result.main.humidity,
                                      pressure: result.main.pressure,
                                      location: location,
                                      time: Date(timeIntervalSince1970: result.dt))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
