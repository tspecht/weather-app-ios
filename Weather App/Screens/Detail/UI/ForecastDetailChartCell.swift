//
//  ForecastDetailTemperatureCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import UIKit
import SnapKit
import SwiftUI

struct ValuePerCategory {
    var category: String
    var value: Double
}

// TODO: Make a protocol for this if somewhat possible
class ForecastDetailChartCellViewModel: ObservableObject {
    let forecast: DayForecast
    let selectedForecastWeather: PassthroughSubject<ForecastWeather?, Never> = PassthroughSubject()

    init(forecast: DayForecast) {
        self.forecast = forecast
    }
}

// TODO: Name can probably be a bit stronger here
class ForecastDetailChartCell: UICollectionViewCell, Reusable {

    private var cancellables = Set<AnyCancellable>()

    lazy var summaryView: ForecastDetailSummaryCell = ForecastDetailSummaryCell(frame: .zero)

    private lazy var chartHostingController: UIHostingController = {
       let hostingVC = UIHostingController(rootView: chartView)
        hostingVC.view.backgroundColor = .clear
        return hostingVC
    }()

    lazy var chartView: ForecastChartView = ForecastChartView()

    private var viewModel: ForecastDetailChartCellViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        addSubviews([
            chartHostingController.view
        ])

        chartHostingController.view.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    func configure(with viewModel: ForecastDetailChartCellViewModel) {
        self.viewModel = viewModel
        chartView.viewModel.forecast = viewModel.forecast
        chartView.viewModel.$selectedIndex
            .sink { selectedIndex in
                guard let selectedIndex = selectedIndex,
                      let forecastWeather = viewModel.forecast.forecasts[safe: selectedIndex] else {
                    viewModel.selectedForecastWeather.send(nil)
                    return
                }
                viewModel.selectedForecastWeather.send(forecastWeather)
            }
            .store(in: &cancellables)
    }
}
