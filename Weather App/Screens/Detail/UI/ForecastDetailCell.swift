//
//  ForecastDetailTemperatureCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Charts
import UIKit
import SnapKit
import SwiftUI

struct ValuePerCategory {
    var category: String
    var value: Double
}

// TODO: Name can probably be a bit stronger here
class ForecastDetailCell: UICollectionViewCell, Reusable {
    lazy var summaryView: ForecastDetailSummaryView = ForecastDetailSummaryView(frame: .zero)
    
    private lazy var chartHostingController: UIHostingController = {
       UIHostingController(rootView: chartView)
    }()
    lazy var chartView: ForecastChartView = {
        
        let viewWModel = ForecastChartViewModel(forecasts: [
            ForecastWeather(temperature: ForecastWeather.Temperature(min: 1, max: 2, feelsLike: 3, average: 4),
                                                                            wind: Wind(speed: 2, gusts: 3, direction: 5),
                                                                            clouds: Clouds(coverage: 12),
                                                                            rain: nil,
                                                                            description: WeatherDescription(icon: .clear,
                                                                                                            description: "asdasd"),
                                                                            humidity: 12, pressure: 12, time: Date(timeIntervalSince1970: 12345)),
            ForecastWeather(temperature: ForecastWeather.Temperature(min: 21, max: 22, feelsLike: 23, average: 24),
                                                                            wind: Wind(speed: 2, gusts: 3, direction: 5),
                                                                            clouds: Clouds(coverage: 12),
                                                                            rain: nil,
                                                                            description: WeatherDescription(icon: .clear,
                                                                                                            description: "asdasd"),
                                                                            humidity: 12, pressure: 12, time: Date(timeIntervalSince1970: 1212312345))
        ])
        return ForecastChartView(viewModel: viewWModel)
//        let data: [ValuePerCategory] = [
//            .init(category: "A", value: 5),
//            .init(category: "B", value: 9),
//            .init(category: "C", value: 7)
//        ]
//        let chart = Chart(data, id: \.category) { item in
//            BarMark(
//                x: .value("Category", item.category),
//                y: .value("Value", item.value)
//            )
//        }
//        let hostingViewController = UIHostingController(rootView: chart)
//        return chart
//        let view = Chart([]) { data in
//
//        }
//        view.backgroundColor = .blue
//        return view
    }()
    
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
            summaryView,
            chartHostingController.view
        ])
        
        summaryView.snp.makeConstraints { make in
            make.left.top.equalTo(self)
            make.right.equalTo(self)  // TODO: Add the value toggle thingy here to the right
            make.height.equalTo(40)
        }
        
        chartHostingController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(summaryView.snp.bottom)
        }
//        addSubview(temperatureLabel)
//        addSubview(locationLabel)
//        addSubview(minTemperatureLabel)
//        addSubview(maxTemperatureLabel)
//        addSubview(descriptionLabel)
//
//        let verticalPadding: CGFloat = 4
//
//        temperatureLabel.snp.makeConstraints { make in
//            make.left.right.equalTo(self)
//            make.centerY.equalTo(self)
//            make.top.equalTo(locationLabel.snp.bottom).offset(verticalPadding)
//        }
//
//        locationLabel.snp.makeConstraints { make in
//            make.left.right.equalTo(self)
//        }
//
//        descriptionLabel.snp.makeConstraints { make in
//            make.left.right.equalTo(self)
//            make.top.equalTo(temperatureLabel.snp.bottom)
//        }
//
//        maxTemperatureLabel.snp.makeConstraints { make in
//            make.top.equalTo(descriptionLabel.snp.bottom).offset(verticalPadding)
//            make.bottom.equalTo(self).inset(verticalPadding)
//            make.right.equalTo(self.snp.centerX).inset(4)
//        }
//
//        minTemperatureLabel.snp.makeConstraints { make in
//            make.top.equalTo(descriptionLabel.snp.bottom).offset(verticalPadding)
//            make.bottom.equalTo(self).inset(verticalPadding)
//            make.left.equalTo(self.snp.centerX).offset(4)
//        }
    }

    func configure(with viewModel: CurrentWeatherCellViewModel) {
//        temperatureLabel.text = viewModel.temperature
//        locationLabel.text = viewModel.location
//        minTemperatureLabel.text = viewModel.minTemperature
//        maxTemperatureLabel.text = viewModel.maxTemperature
//        descriptionLabel.text = viewModel.description
    }
}
