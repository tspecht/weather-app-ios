//
//  ForecastDetailSummaryCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import UIKit
import SnapKit

// TODO: Consider moving to separate file
struct ForecastDetailSummaryCellViewModel {
    
    enum Mode {
        case today, forecast, hidden
    }
    
    let temperature: String
    let temperatureRange: String
    let iconImage: UIImage
    let mode: Mode

    init(dayForecast: DayForecast, mode: Mode) {
        // TODO: This should be the current temperature maybe if its today?
        self.temperature = "\(Int(dayForecast.middleForecast.temperature.average))°"
        self.temperatureRange = "H:\(Int(dayForecast.maxTemperature ?? 0))° L:\(Int(dayForecast.minTemperature ?? 0))°"
        self.iconImage = dayForecast.middleForecast.description.iconImageAsset.image
        self.mode = mode
    }
}

class ForecastDetailSummaryCell: UICollectionViewCell, Reusable {
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        return label
    }()

    private lazy var temperatureRangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
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
            temperatureLabel,
            temperatureRangeLabel,
            iconImageView
        ])

        temperatureLabel.snp.makeConstraints { make in
            make.top.left.equalTo(self)
        }

        temperatureRangeLabel.snp.makeConstraints { make in
            make.left.bottom.equalTo(self)
            make.height.equalTo(12)
            make.top.equalTo(temperatureLabel.snp.bottom)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(temperatureLabel)
            make.left.equalTo(temperatureLabel.snp.right)
            make.width.equalTo(26)
        }
    }

    func configure(with viewModel: ForecastDetailSummaryCellViewModel) {
        temperatureLabel.text = viewModel.temperature
        temperatureRangeLabel.text = viewModel.temperatureRange
        iconImageView.image = viewModel.iconImage
        
        switch viewModel.mode {
        case .hidden:
            temperatureLabel.isHidden = true
            temperatureRangeLabel.isHidden = true
            iconImageView.isHidden = true
        default:
            temperatureLabel.isHidden = false
            temperatureRangeLabel.isHidden = false
            iconImageView.isHidden = false
        }
    }
}
