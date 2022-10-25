//
//  ForecastDetailViewModel.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import Foundation

protocol ForecastDetailViewModel {
    init(forecasts: [DayForecast], initialIndex: Int)
}

class ForecastDetailViewModelImpl: ForecastDetailViewModel {
    
    private let forecasts: [DayForecast]
    private let activeForecast: DayForecast
    
    required init(forecasts: [DayForecast], initialIndex: Int) {
        self.forecasts = forecasts
        self.activeForecast = forecasts[initialIndex]
    }
}
