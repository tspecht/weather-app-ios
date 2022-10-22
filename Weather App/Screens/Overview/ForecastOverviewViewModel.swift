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

    init(location: Location, dataSource: DataSource)
    func loadCurrentWeather() -> AnyPublisher<Bool, DataSourceError>
    func loadDailyForecast() -> AnyPublisher<Bool, DataSourceError>
}

struct ForecastOverview {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case current(CurrentWeather)
        case daily(DayForecast)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .current(let currentWeather):
                hasher.combine(currentWeather.time)
            case .daily(let forecast):
                hasher.combine(forecast.date)
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
    private let location: Location

    required init(location: Location, dataSource: DataSource) {
        self.location = location
        self.dataSource = dataSource
    }

    private func updateSnapshot() {
        var snapshot = ForecastOverview.Snapshot()

        if let currentWeather = currentWeather {
            snapshot.appendSections([.current])
            snapshot.appendItems([.current(currentWeather)], toSection: .current)
        }

        if let dailyForecasts = dailyForecasts {
            snapshot.appendSections([.dailyForecast])
            snapshot.appendItems(dailyForecasts.map { .daily($0) }, toSection: .dailyForecast)
        }

        dataUpdated.send(snapshot)
    }

    // TODO: We probably want to return a bool publisher here and write to currentWeather using handleEvents as a side-effect.
    // This will require the caller to hold the cancellable though, need to think about if that should be the case
    func loadCurrentWeather() -> AnyPublisher<Bool, DataSourceError> {
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

    func loadDailyForecast() -> AnyPublisher<Bool, DataSourceError> {
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
