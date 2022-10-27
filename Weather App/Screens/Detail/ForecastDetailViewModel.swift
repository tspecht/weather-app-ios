//
//  ForecastDetailViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import Foundation
import UIKit

protocol ForecastDetailViewModel {
    var initialIndex: Int { get }
    var dataUpdated: AnyPublisher<ForecastDetail.Snapshot, Never> { get }
    init(forecasts: [DayForecast], initialIndex: Int)
    func select(forecastWeather: ForecastWeather?)
    func select(activeForecast: DayForecast)
}

// TODO: Move this to a separate file
struct ForecastDetail {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case summary(DayForecast, ForecastWeather?)
        case charts([DayForecast])

        func hash(into hasher: inout Hasher) {
            switch self {
            case .summary(let dayForecast, let forecastWeather):
                hasher.combine(dayForecast.date)
                hasher.combine(forecastWeather?.time)
            case .charts(let dayForecasts):
                dayForecasts.forEach {
                    hasher.combine($0.date)
                }
            }
        }
    }

    enum Section: Int {
        // TODO: Move the summarz out of the detail cell, it doesn‘t need to be all in one
        case detail
        case charts
    }
}

class ForecastDetailViewModelImpl: ForecastDetailViewModel {

    private let dataUpdatedCurrentValueSubject: CurrentValueSubject<ForecastDetail.Snapshot?, Never> = CurrentValueSubject(nil)
    var dataUpdated: AnyPublisher<ForecastDetail.Snapshot, Never> {
        dataUpdatedCurrentValueSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    private let forecasts: [DayForecast]
    private var activeForecast: DayForecast {
        didSet {
            updateSnapshot()
        }
    }
    private var selectedForecastWeather: ForecastWeather? {
        didSet {
            updateSnapshot()
        }
    }

    let initialIndex: Int

    required init(forecasts: [DayForecast], initialIndex: Int) {
        self.initialIndex = initialIndex
        self.forecasts = forecasts
        self.activeForecast = forecasts[initialIndex]
        updateSnapshot()
    }

    func select(forecastWeather: ForecastWeather?) {
        selectedForecastWeather = forecastWeather
    }

    func select(activeForecast: DayForecast) {
        self.activeForecast = activeForecast
    }

    private func updateSnapshot() {
        var snapshot = ForecastDetail.Snapshot()
        snapshot.appendSections([.detail, .charts])
        snapshot.appendItems([.summary(activeForecast, selectedForecastWeather)], toSection: .detail)
        snapshot.appendItems([.charts(forecasts)], toSection: .charts)
        dataUpdatedCurrentValueSubject.send(snapshot)
    }
}
