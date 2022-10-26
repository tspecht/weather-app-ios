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
    var dataUpdated: AnyPublisher<ForecastDetail.Snapshot, Never> { get }
    init(forecasts: [DayForecast], initialIndex: Int)
}

// TODO: Move this to a separate file
struct ForecastDetail {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case summary(DayForecast)
        case chart(DayForecast)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .summary(let dayForecast):
                hasher.combine(dayForecast.date)
            case .chart(let dayForecast):
                hasher.combine(dayForecast.date)
            }
        }
    }

    enum Section: Int {
        // TODO: Move the summarz out of the detail cell, it doesn‘t need to be all in one
        case detail
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

    required init(forecasts: [DayForecast], initialIndex: Int) {
        self.forecasts = forecasts
        self.activeForecast = forecasts[initialIndex]
        updateSnapshot()
    }

    private func updateSnapshot() {
        var snapshot = ForecastDetail.Snapshot()
        snapshot.appendSections([.detail])
        snapshot.appendItems([.summary(activeForecast), .chart(activeForecast)], toSection: .detail)
        dataUpdatedCurrentValueSubject.send(snapshot)
    }
}
