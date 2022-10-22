//
//  CurrentWeatherCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import UIKit
import SnapKit

private let kDefaultFontName = "HelveticaNeue-Thin"

// TODO: Does this need it's own view model?
class CurrentWeatherCell: UICollectionViewCell, Reusable {
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kDefaultFontName, size: 24)
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kDefaultFontName, size: 64)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kDefaultFontName, size: 16)
        return label
    }()

    lazy var minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kDefaultFontName, size: 16)
        return label
    }()

    lazy var maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: kDefaultFontName, size: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        addSubview(temperatureLabel)
        addSubview(locationLabel)
        addSubview(minTemperatureLabel)
        addSubview(maxTemperatureLabel)
        addSubview(descriptionLabel)

        let verticalPadding: CGFloat = 4

        temperatureLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.centerY.equalTo(self)
            make.top.equalTo(locationLabel.snp.bottom).offset(verticalPadding)
        }

        locationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(temperatureLabel.snp.top).offset(verticalPadding)
            make.left.right.equalTo(self)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.equalTo(temperatureLabel.snp.bottom)
        }

        maxTemperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(verticalPadding)
            make.bottom.equalTo(self).inset(verticalPadding)
            make.right.equalTo(self.snp.centerX).inset(4)
        }

        minTemperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(verticalPadding)
            make.bottom.equalTo(self).inset(verticalPadding)
            make.left.equalTo(self.snp.centerX).offset(4)
        }
    }
}
