//
//  OpenMeteoDataSource.swift
//  Weather App
//
//  Created by Tim Specht on 10/22/22.
//

import Combine
import Foundation

struct OpenMeteoForecastResponse: Codable {

    struct Hourly: Codable {
        enum CodingKeys: String, CodingKey {
            case time
            case temperature = "temperature_2m"
            case relativeHumidity = "relativehumidity_2m"
            case apparentTemperature = "apparent_temperature"
            case pressure = "pressure_msl"
            case cloudCover = "cloudcover"
            case windSpeed = "windspeed_10m"
            case windDirection = "winddirection_10m"
            case windGusts = "windgusts_10m"
            case precipitation
            case weatherCode = "weathercode"
        }

        let time: [Int]
        let temperature: [Float]
        let relativeHumidity: [Int]
        let apparentTemperature: [Float]
        let pressure: [Float]
        let cloudCover: [Int]
        let windSpeed: [Float]
        let windDirection: [Int]
        let windGusts: [Float]
        let precipitation: [Float]
        let weatherCode: [Int]

        static func weatherDescription(for code: Int) -> WeatherDescription {
            switch code {
            case 0:
                return WeatherDescription(icon: .clear, description: "Clear sky")
            case 1:
                return WeatherDescription(icon: .scatteredClouds, description: "Mainly clear sky")
            case 2:
                return WeatherDescription(icon: .partlyCloudy, description: "Partly cloudy")
            case 3:
                return WeatherDescription(icon: .brokenClouds, description: "Overcast")
            // 45, 48 Fog and depositing rime fog
            case 51, 53, 55:
                return WeatherDescription(icon: .mist, description: "Drizzle")
            case 61, 63, 64:
                return WeatherDescription(icon: .rain, description: "Rain")
            // 66, 67 Freezing Rain: Light and heavy intensity
            case 71, 73, 75, 77:
                return WeatherDescription(icon: .snow, description: "Snow")
            case 80, 81, 82:
                return WeatherDescription(icon: .showers, description: "Rain showers")
            case 95, 96, 99:
                return WeatherDescription(icon: .thunderstorm, description: "Thunderstorm")
            default:
                return WeatherDescription(icon: .clear, description: "Unknown")
            }
        }
    }

    struct Current: Codable {
        let time: Int
    }

    enum CodingKeys: String, CodingKey {
        case hourly, current = "current_weather"
    }

    let hourly: Hourly
    let current: Current
}

class OpenMeteoDataSource: DataSource {

    enum Error: Swift.Error {
        case cantConstructRequest
        case cantFindTodaysForecast
        case noSelf
    }

    private lazy var isoCalendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private let networkClient: NetworkClient

    required init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func dailyForecast(for location: Location) -> AnyPublisher<[DayForecast], DataSourceError> {
        return dailyForecastIncludingCurrent(for: location)
            .map { $0.0 }
            .eraseToAnyPublisher()
    }

    private func dailyForecastIncludingCurrent(for location: Location) -> AnyPublisher<([DayForecast], Date), DataSourceError> {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&hourly=temperature_2m,relativehumidity_2m,apparent_temperature,pressure_msl,cloudcover,windspeed_10m,winddirection_10m,windgusts_10m,precipitation,weathercode&current_weather=true&timezone=UTC&timeformat=unixtime") else {
            return Fail(error: DataSourceError.networkError(underlyingError: OpenWeatherDataSource.Error.cantConstructRequest)).eraseToAnyPublisher()
        }
        return networkClient
            .getData(url, responseType: OpenMeteoForecastResponse.self)
            .mapError { error in
                return DataSourceError.networkError(underlyingError: error)
            }
            .tryMap { [weak self] response in
                guard let self = self else {
                    throw OpenMeteoDataSource.Error.noSelf
                }

                let hourlyData = response.hourly
                let forecastWeathers = hourlyData.time.enumerated().compactMap { (index, unixTime) -> ForecastWeather? in
                    guard let temperature = hourlyData.temperature[safe: index],
                          let humidity = hourlyData.relativeHumidity[safe: index],
                          let feelsLike = hourlyData.apparentTemperature[safe: index],
                          let pressure = hourlyData.pressure[safe: index],
                          let clouds = hourlyData.cloudCover[safe: index],
                          let windSpeed = hourlyData.windSpeed[safe: index],
                          let windDirection = hourlyData.windDirection[safe: index],
                          let windGusts = hourlyData.windGusts[safe: index],
                          let precipitation = hourlyData.precipitation[safe: index],
                          let weatherCode = hourlyData.weatherCode[safe: index] else {
                        return nil
                    }

                    let rain = precipitation > 0 ? Rain(hourly: precipitation) : nil
                    return ForecastWeather(temperature: ForecastWeather.Temperature(min: temperature,
                                                                                    max: temperature,
                                                                                    feelsLike: feelsLike,
                                                                                    average: temperature),
                                           wind: Wind(speed: windSpeed,
                                                      gusts: windGusts,
                                                      direction: windDirection),
                                           clouds: Clouds(coverage: clouds),
                                           rain: rain,
                                           description: OpenMeteoForecastResponse.Hourly.weatherDescription(for: weatherCode),
                                           humidity: humidity,
                                           pressure: Int(pressure),
                                           time: Date(timeIntervalSince1970: TimeInterval(unixTime)))
                }

                // TODO: This is the same as for the OpenWeather response, needs to be a helper of sorts
                // Group by date next
                let groupedByDate: [Date: [ForecastWeather]] = forecastWeathers.reduce([:]) { partialResult, forecastWeather in
                    var partialResult = partialResult
                    let dateComponents = self.isoCalendar.dateComponents([.day, .month, .year], from: forecastWeather.time)
                    if let date = self.isoCalendar.date(from: dateComponents) {
                        partialResult[date, default: []].append(forecastWeather)
                    }
                    return partialResult
                }

                // Build the final DayForecast objects
                return (groupedByDate.reduce([]) { partialResult, item in
                    let (key, value) = item
                    var partialResult = partialResult
                    partialResult.append(DayForecast(date: key, forecasts: value))
                    return partialResult
                }.sorted(), Date(timeIntervalSince1970: TimeInterval(response.current.time)))
            }
            .mapError { DataSourceError.networkError(underlyingError: $0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func currentWeather(for location: Location) -> AnyPublisher<CurrentWeather, DataSourceError> {
        return dailyForecastIncludingCurrent(for: location)
            .tryMap({ (dayForecasts, currentDate) -> CurrentWeather in
                guard let currentForecast = dayForecasts.flatMap({ $0.forecasts }).first(where: { $0.time == currentDate }) else {
                    throw OpenMeteoDataSource.Error.cantFindTodaysForecast
                }

                return CurrentWeather(temperature: CurrentWeather.Temperature(current: currentForecast.temperature.average,
                                                                              feelsLike: currentForecast.temperature.feelsLike),
                                      wind: currentForecast.wind,
                                      clouds: currentForecast.clouds,
                                      rain: currentForecast.rain,
                                      description: currentForecast.description,
                                      humidity: currentForecast.humidity,
                                      pressure: currentForecast.pressure,
                                      location: location,
                                      time: currentForecast.time)
            })
            .mapError { DataSourceError.networkError(underlyingError: $0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
