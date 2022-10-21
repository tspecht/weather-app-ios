//
//  CurrentWeatherCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import UIKit
import SnapKit

// TODO: Does this need it's own view model?
class CurrentWeatherCell: UICollectionViewCell, Reusable {

    static let reuseIdentifier = "CurrentWeatherCell"

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
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
        addSubview(feelsLikeLabel)

        locationLabel.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(20)
        }

        temperatureLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.equalTo(locationLabel.snp.bottom)
        }

        feelsLikeLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self)
            make.top.equalTo(temperatureLabel.snp.bottom)
        }
    }
}
