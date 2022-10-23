//
//  OpenMeteoDataSource.swift
//  Weather App
//
//  Created by Tim Specht on 10/22/22.
//

import Combine
import Foundation

struct OpenMeteoForecastResponse: Codable {

}

class OpenMeteoDataSource: DataSource {

    enum Error: Swift.Error {
        case cantConstructRequest
    }

    private let networkClient: NetworkClient

    required init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
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
                                           clouds: Clouds(coverage: result.clouds.all),
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
        // TODO: See if we can use some form of URL transformer here to always append the appId in code instead of building it as a string
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,rain_sum,weathercode,windspeed_10m_max,windgusts_10m_max,winddirection_10m_dominant") else {
            return Fail(error: DataSourceError.networkError(underlyingError: OpenWeatherDataSource.Error.cantConstructRequest)).eraseToAnyPublisher()
        }
        // TODO: Might as well call daily here and filter afterwards
        return networkClient
            .getData(url, responseType: OpenMeteoForecastResponse.self)
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .map { _ in
                retur
                // TODO: This whole mapping voodoo could be moved via a protocol to the API struct defined above
//                let currentRain: Rain?
//                if let openWeatherRain = result.rain,
//                   let perHour = openWeatherRain.perHour {
//                    currentRain = Rain(hourly: perHour)
//                } else {
//                    currentRain = nil
//                }
//
//                return CurrentWeather(temperature: CurrentWeather.Temperature(current: result.main.temp,
//                                                                              feelsLike: result.main.feelsLike),
//                                      wind: Wind(speed: result.wind.speed,
//                                                 gusts: result.wind.gust,
//                                                 direction: result.wind.deg),
//                                      clouds: Clouds(coverage: result.clouds.all),
//                                      rain: currentRain,
//                                      description: WeatherDescription(icon: result.weather[0].asWeatherDescriptionIcon, description: result.weather[0].description),
//                                      humidity: result.main.humidity,
//                                      pressure: result.main.pressure,
//                                      location: location,
//                                      time: Date(timeIntervalSince1970: result.dt))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
