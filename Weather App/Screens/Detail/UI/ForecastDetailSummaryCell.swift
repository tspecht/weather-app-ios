//
//  ForecastDetailSummaryCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import UIKit
import SnapKit

private let dateFormatter = DateFormatter(dateStyle: .long)

// TODO: Consider moving to separate file
struct ForecastDetailSummaryCellViewModel {

    enum Mode {
        case today, forecast, hidden
    }

    let temperature: String
    let minTemperature: String
    let temperatureRange: String
    let date: String
    let iconImage: UIImage
    let mode: Mode

    init(dayForecast: DayForecast, mode: Mode) {
        // TODO: This should be the current temperature maybe if its today?
        switch mode {
        case .today:
            self.temperature = "\(Int(dayForecast.middleForecast.temperature.average))°"
        case .forecast:
            self.temperature = "\(Int(dayForecast.maxTemperature ?? 0))°"
        default:
            self.temperature = ""
        }
        self.date = dateFormatter.string(from: dayForecast.date)
        self.minTemperature = "\(Int(dayForecast.minTemperature ?? 0))°"
        self.temperatureRange = "H:\(Int(dayForecast.maxTemperature ?? 0))° L:\(Int(dayForecast.minTemperature ?? 0))°"
        self.iconImage = dayForecast.middleForecast.description.iconImageAsset.image
        self.mode = mode
    }
}

class ForecastDetailSummaryCell: UICollectionViewCell, Reusable {
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, minTemperatureLabel, iconImageView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 8
        return stackView
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var temperatureRangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        return label
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
            dateLabel,
            topStackView,
            temperatureRangeLabel
        ])

        temperatureRangeLabel.snp.makeConstraints { make in
            make.left.bottom.equalTo(self)
            make.height.equalTo(12)
        }

        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.equalTo(self).offset(8)
            make.height.equalTo(24)
        }

        topStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(temperatureRangeLabel.snp.top).offset(8)
        }

        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(26)
        }
    }

    func configure(with viewModel: ForecastDetailSummaryCellViewModel) {
        temperatureLabel.text = viewModel.temperature
        minTemperatureLabel.text = viewModel.minTemperature
        temperatureRangeLabel.text = viewModel.temperatureRange
        iconImageView.image = viewModel.iconImage
        dateLabel.text = viewModel.date

        switch viewModel.mode {
        case .hidden:
            temperatureLabel.isHidden = true
            temperatureRangeLabel.isHidden = true
            iconImageView.isHidden = true
            minTemperatureLabel.isHidden = true
            dateLabel.isHidden = true
        case .today:
            topStackView.isHidden = false
            dateLabel.isHidden = false
            temperatureRangeLabel.isHidden = false

            minTemperatureLabel.removeFromSuperview()
        case .forecast:
            topStackView.isHidden = false
            dateLabel.isHidden = false
            temperatureRangeLabel.isHidden = false

            if minTemperatureLabel.superview == nil {
                topStackView.insertArrangedSubview(minTemperatureLabel, at: 1)
            }
        }
    }
}
