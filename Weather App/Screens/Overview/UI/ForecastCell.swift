//
//  ForecastCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/21/22.
//

import UIKit

class ForecastCell: UICollectionViewCell, Reusable {
    lazy var dateLabel: UILabel = {
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        addSubview(temperatureLabel)
        addSubview(dateLabel)

        dateLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self)
        }

        temperatureLabel.snp.makeConstraints { make in
            make.left.equalTo(dateLabel.snp.right)
            make.top.bottom.equalTo(self)
        }
    }
}
