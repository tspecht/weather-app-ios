//
//  ForecastOverviewViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Combine
import UIKit

protocol ForecastOverviewViewModel {
    var dataUpdated: PassthroughSubject<ForecastOverview.Snapshot, DataSourceError> { get }

    init(locationProvider: LocationProvider, dataSource: DataSource)

    func reload() -> AnyPublisher<Bool, Swift.Error>
//    func loadCurrentWeather() -> AnyPublisher<Bool, DataSourceError>
//    func loadDailyForecast() -> AnyPublisher<Bool, DataSourceError>
}

// TODO: Probably move to own file as well
struct ForecastOverview {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case current(CurrentWeather, Float?, Float?)
        case daily(DayForecast, Float, Float, [DayForecast])

        func hash(into hasher: inout Hasher) {
            switch self {
            case .current(let currentWeather, let min, let max):
                hasher.combine(currentWeather.time)
                hasher.combine(min ?? 0)
                hasher.combine(max ?? 0)
            case .daily(let forecast, let min, let max, let allForecasts):
                hasher.combine(forecast.date)
                hasher.combine(min)
                hasher.combine(max)
                allForecasts.forEach {
                    hasher.combine($0.date)
                }
            }
        }
    }

    enum Section: Int {
        case current, dailyForecast
    }
}

class ForecastOverviewViewModelImpl: ForecastOverviewViewModel {

    var dataUpdated: PassthroughSubject<ForecastOverview.Snapshot, DataSourceError> = PassthroughSubject()

    // TODO: There must be a more reactive, nicer way to keep track of this
    private var currentWeather: CurrentWeather? {
        didSet {
            updateSnapshot()
        }
    }
    private var dailyForecasts: [DayForecast]? {
        didSet {
            updateSnapshot()
        }
    }

    private let dataSource: DataSource
    private let locationProvider: LocationProvider

    required init(locationProvider: LocationProvider, dataSource: DataSource) {
        self.locationProvider = locationProvider
        self.dataSource = dataSource
    }

    private func updateSnapshot() {
        var snapshot = ForecastOverview.Snapshot()

        if let currentWeather = currentWeather {

            // See if we pulled todays forecast already and include min and max for today
            let minTemperature: Float?
            let maxTemperature: Float?
            if let dailyForecasts = dailyForecasts,
               let todaysForecast = dailyForecasts.filter({ Calendar.current.isDateInToday($0.date) }).first {
                   minTemperature = todaysForecast.minTemperature
                   maxTemperature = todaysForecast.maxTemperature
           } else {
               minTemperature = nil
               maxTemperature = nil
           }

            snapshot.appendSections([.current])
            snapshot.appendItems([.current(currentWeather, minTemperature, maxTemperature)], toSection: .current)
        }

        if let dailyForecasts = dailyForecasts {
            snapshot.appendSections([.dailyForecast])

            let maxTemperature = dailyForecasts.compactMap { $0.maxTemperature }.max() ?? 100
            let minTemperature = dailyForecasts.compactMap { $0.minTemperature }.min() ?? 0

            snapshot.appendItems(dailyForecasts.map { .daily($0, minTemperature, maxTemperature, dailyForecasts) }, toSection: .dailyForecast)
        }

        dataUpdated.send(snapshot)
    }

    func reload() -> AnyPublisher<Bool, Swift.Error> {
        return locationProvider.location()
            .compactMap { $0 } // Effectively filter nil
            .first()
            .flatMap({ location in
                Publishers.Zip(self.loadDailyForecast(for: location), self.loadCurrentWeather(for: location))
                    .map { (dailySuccess, currentSuccess) in
                        // This makes sure both were successful, but probably not the best. Would be nice to be able to pull these apart on the VX sides
                        return dailySuccess && currentSuccess
                    }
                    .mapError {
                        $0 as Swift.Error
                    }
            })
            .eraseToAnyPublisher()
    }
}

internal extension ForecastOverviewViewModelImpl {
    func loadCurrentWeather(for location: Location) -> AnyPublisher<Bool, DataSourceError> {
        return dataSource.currentWeather(for: location)
            .handleEvents(receiveOutput: { [weak self] weather in
                self?.currentWeather = weather
            }, receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    // TODO: There has to be a better way to propagate this error
                    print(error)
                    self?.currentWeather = nil
                default:
                    break
                }
            })
            .map { _ in true }
            .eraseToAnyPublisher()
    }

    func loadDailyForecast(for location: Location) -> AnyPublisher<Bool, DataSourceError> {
        dataSource.dailyForecast(for: location)
            .handleEvents(receiveOutput: { [weak self] dailyForecasts in
                self?.dailyForecasts = dailyForecasts
            }, receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    // TODO: There has to be a better way to propagate this error
                    print(error)
                    self?.dailyForecasts = nil
                default:
                    break
                }
            })
            .map { _ in true }
            .eraseToAnyPublisher()
    }
}
