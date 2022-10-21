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

private struct OpenWeatherCloudsResponse: Codable {
    let all: Float
}

private struct OpenWeatherWeatherResponse: Codable {
    let main: OpenWeatherMainResponse
    let wind: OpenWeatherWindResponse
    let rain: OpenWeatherRainResponse?
    let clouds: OpenWeatherCloudsResponse
    let dt: Double
}

private struct OpenWeatherDailyForecastResponse: Codable {
    let list: [OpenWeatherWeatherResponse]
}

class OpenWeatherDataSource: DataSource {
    private let apiKey: String
    private let session: Alamofire.Session

    required init(session: Alamofire.Session, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric&exclude=hourly,minutely") else {
            return Fail(error: .cantConstructRequest).eraseToAnyPublisher()
        }
        return session.request(url, method: .get)
            .validate()
            .publishDecodable(type: OpenWeatherDailyForecastResponse.self)
            .value()
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .map { result in

                // Convert all the data at first
                let forecastWeathers = result.list.compactMap { response -> ForecastWeather? in
                    // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
                    guard let tempMin = response.main.tempMin,
                          let tempMax = response.main.tempMax else {
                        return nil
                    }
                    let rain: Rain?
                    if let openWeatherRain = response.rain,
                       let perThreeHours = openWeatherRain.perThreeHours {
                        rain = Rain(hourly: perThreeHours)  // TODO: This isn't correct
                    } else {
                        rain = nil
                    }
                    return ForecastWeather(temperature: ForecastWeather.Temperature(min: tempMin,
                                                                                    max: tempMax,
                                                                                    feelsLike: response.main.feelsLike,
                                                                                    average: response.main.temp),
                                           wind: Wind(speed: response.wind.speed,
                                                      gusts: response.wind.gust,
                                                      direction: response.wind.deg),
                                           clouds: Clouds(coverage: response.clouds.all),
                                           rain: rain,
                                           humidity: response.main.humidity,
                                           pressure: response.main.pressure,
                                           time: Date(timeIntervalSince1970: response.dt))
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
        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric&exclude=hourly,minutely") else {
            return Fail(error: .cantConstructRequest).eraseToAnyPublisher()
        }
        return session.request(url, method: .get)
            .validate()
            .publishDecodable(type: OpenWeatherWeatherResponse.self)
            .value()
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
