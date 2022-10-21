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
    func loadCurrentWeather()
    func loadDailyForecast()
}

struct ForecastOverview {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case current(CurrentWeather)
        case daily([ForecastWeather])

        func hash(into hasher: inout Hasher) {
            switch self {
            case .current(let currentWeather):
                hasher.combine(currentWeather.time)
            case .daily(let forecasts):
                hasher.combine(forecasts.map({ "\($0.time.timeIntervalSince1970)" }).reduce("", +))
            }
        }
    }

    enum Section: Int {
        case current, dailyForecast
    }
}

class WeatherOverviewViewModelImpl: ForecastOverviewViewModel {

    var dataUpdated: PassthroughSubject<ForecastOverview.Snapshot, DataSourceError> = PassthroughSubject()

    // TODO: There must be a more reactive, nicer way to keep track of this
    private var currentWeather: CurrentWeather? {
        didSet {
            updateSnapshot()
        }
    }
    private let dataSource: DataSource
    private let location: Location
    private var cancellables = Set<AnyCancellable>()

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

        dataUpdated.send(snapshot)
    }

    func loadCurrentWeather() {
        dataSource.currentWeather(for: location)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    // TODO: There has to be a better way to propagate this error
                    self?.currentWeather = nil
                default:
                    break
                }
            }) { [weak self] currentWeather in
                self?.currentWeather = currentWeather
            }
            .store(in: &cancellables)

    }

    func loadDailyForecast() {
//        dataSource.forecast(for: location)
//            .sink { [weak self] result in
//                // TODO: Propagate error
//            } receiveValue: { <#Forecast#> in
//                <#code#>
//            }

    }
}
