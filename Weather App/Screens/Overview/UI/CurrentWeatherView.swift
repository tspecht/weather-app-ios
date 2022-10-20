//
//  CurrentWeatherView.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import UIKit
import SnapKit

// TODO: Does this need it's own view model?
class CurrentWeatherView: UIView {
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
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

        temperatureLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(32)
        }

        locationLabel.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(temperatureLabel.snp.top)
        }
    }
}
