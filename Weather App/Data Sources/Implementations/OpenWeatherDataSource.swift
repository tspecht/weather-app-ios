//
//  OpenWeather.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Foundation
import Combine
import Alamofire

// TODO: Move all of these to a separate file
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

private struct OpenWeatherMainResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case temp, tempMin = "temp_min", tempMax = "temp_max", feelsLike = "feels_like", humidity, pressure
    }

    let temp: Float
    let tempMin: Float?
    let tempMax: Float?
    let feelsLike: Float
    let humidity: Int
    let pressure: Int
}

private struct OpenWeatherWindResponse: Codable {
    let speed: Float
    let gust: Float?
    let deg: Int
}

private struct OpenWeatherRainResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case perHour = "1h", perThreeHours = "3h"
    }
    let perHour: Float?
    let perThreeHours: Float?
}

private struct OpenWeatherWeatherSubResponse: Codable {
    let icon: String
    let description: String

    var asWeatherDescriptionIcon: WeatherDescription.Icon {
        switch icon {
        case "01d", "01n":
            return .clear
        case "02d", "02n":
            return .partlyCloudy
        case "03d", "03n":
            return .scatteredClouds
        case "04d", "04n":
            return .brokenClouds
        case "09d", "09n":
            return .showers
        case "10d", "10n":
            return .rain
        case "11d", "11n":
            return .thunderstorm
        case "13d", "13n":
            return .snow
        case "50d", "50n":
            return .mist
        default:
            return .clear
        }
    }
}

private struct OpenWeatherCloudsResponse: Codable {
    let all: Float
}

private struct OpenWeatherWeatherResponse: Codable {
    let main: OpenWeatherMainResponse
    let wind: OpenWeatherWindResponse
    let rain: OpenWeatherRainResponse?
    let clouds: OpenWeatherCloudsResponse
    let weather: [OpenWeatherWeatherSubResponse]
    let dt: Double
}

private struct OpenWeatherDailyForecastResponse: Codable {
    let list: [OpenWeatherWeatherResponse]
}

class OpenWeatherDataSource: DataSource {

    enum Error: Swift.Error {
        case cantConstructRequest
    }

    private let networkClient: NetworkClient

    required init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&exclude=hourly,minutely") else {
            return Fail(error: DataSourceError.networkError(underlyingError: OpenWeatherDataSource.Error.cantConstructRequest)).eraseToAnyPublisher()
        }
        return networkClient
            .getData(url, responseType: OpenWeatherDailyForecastResponse.self)
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .map { response in

                // Convert all the data at first
                let forecastWeathers = response.list.compactMap { result -> ForecastWeather? in
                    // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
                    guard let tempMin = result.main.tempMin,
                          let tempMax = result.main.tempMax else {
                        return nil
                    }
                    let rain: Rain?
                    if let openWeatherRain = result.rain,
                       let perThreeHours = openWeatherRain.perThreeHours {
                        rain = Rain(hourly: perThreeHours)  // TODO: This isn't correct
                    } else {
                        rain = nil
                    }
                    return ForecastWeather(temperature: ForecastWeather.Temperature(min: tempMin,
                                                                                    max: tempMax,
                                                                                    feelsLike: result.main.feelsLike,
                                                                                    average: result.main.temp),
                                           wind: Wind(speed: result.wind.speed,
                                                      gusts: result.wind.gust,
                                                      direction: result.wind.deg),
                                           clouds: Clouds(coverage: Int(result.clouds.all)),
                                           rain: rain,
                                           description: WeatherDescription(icon: result.weather[0].asWeatherDescriptionIcon, description: result.weather[0].description),
                                           humidity: result.main.humidity,
                                           pressure: result.main.pressure,
                                           time: Date(timeIntervalSince1970: result.dt))
                }

                // Group by date next
                let calendar = Calendar.current
                let groupedByDate: [Date: [ForecastWeather]] = forecastWeathers.reduce([:]) { partialResult, forecastWeather in
                    var partialResult = partialResult
                    let dateComponents = calendar.dateComponents([.day, .month, .year], from: forecastWeather.time)
                    if let date = calendar.date(from: dateComponents) {
                        partialResult[date, default: []].append(forecastWeather)
                    }
                    return partialResult
                }

                // Build the final DayForecast objects
                return groupedByDate.reduce([]) { partialResult, item in
                    let (key, value) = item
                    var partialResult = partialResult
                    partialResult.append(DayForecast(date: key, forecasts: value))
                    return partialResult
                }.sorted()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&exclude=hourly,minutely") else {
            return Fail(error: DataSourceError.networkError(underlyingError: OpenWeatherDataSource.Error.cantConstructRequest)).eraseToAnyPublisher()
        }
        return networkClient
            .getData(url, responseType: OpenWeatherWeatherResponse.self)
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .map { result in
                // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
                let currentRain: Rain?
                if let openWeatherRain = result.rain,
                   let perHour = openWeatherRain.perHour {
                    currentRain = Rain(hourly: perHour)
                } else {
                    currentRain = nil
                }

                return CurrentWeather(temperature: CurrentWeather.Temperature(current: result.main.temp,
                                                                              feelsLike: result.main.feelsLike),
                                      wind: Wind(speed: result.wind.speed,
                                                 gusts: result.wind.gust,
                                                 direction: result.wind.deg),
                                      clouds: Clouds(coverage: Int(result.clouds.all)),
                                      rain: currentRain,
                                      description: WeatherDescription(icon: result.weather[0].asWeatherDescriptionIcon, description: result.weather[0].description),
                                      humidity: result.main.humidity,
                                      pressure: result.main.pressure,
                                      location: location,
                                      time: Date(timeIntervalSince1970: result.dt))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
