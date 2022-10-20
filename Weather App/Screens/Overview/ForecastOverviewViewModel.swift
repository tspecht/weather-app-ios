//
//  ForecastOverviewViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Combine
import Foundation

protocol ForecastOverviewViewModel {
    var currentWeather: PassthroughSubject<CurrentWeather, DataSourceError> { get }

    init(location: Location, dataSource: DataSource)
    func loadCurrentWeather()
}

class WeatherOverviewViewModelImpl: ForecastOverviewViewModel {
    var currentWeather: PassthroughSubject<CurrentWeather, DataSourceError> = PassthroughSubject()

    private let dataSource: DataSource
    private let location: Location
    private var cancellables = Set<AnyCancellable>()

    required init(location: Location, dataSource: DataSource) {
        self.location = location
        self.dataSource = dataSource
    }

    func loadCurrentWeather() {
        dataSource.currentWeather(for: location)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.currentWeather.send(completion: .failure(error))
                default:
                    break
                }
            }) { currentWeather in
                self.currentWeather.send(currentWeather)
            }
            .store(in: &cancellables)

    }
}
