//
//  ForecastCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/21/22.
//

import UIKit

private let kDefaultFontSize: CGFloat = 20
private let kDefaultFont = UIFont(name: "HelveticaNeue-Medium", size: kDefaultFontSize)

class ForecastCell: UICollectionViewCell, Reusable {
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = kDefaultFont
        return label
    }()

    lazy var maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = kDefaultFont
        return label
    }()

    lazy var minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.alpha = 0.7
        label.font = kDefaultFont
        return label
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        addSubview(maxTemperatureLabel)
        addSubview(minTemperatureLabel)
        addSubview(dateLabel)
        addSubview(iconImageView)

        let verticalSpace = 4
        let sideSpace = 8

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(verticalSpace)
            make.bottom.equalTo(self).inset(verticalSpace)
            make.left.equalTo(self).offset(sideSpace)
            make.width.equalTo(self).multipliedBy(0.15)
        }

        minTemperatureLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.left.equalTo(self.snp.centerX)
            make.top.bottom.equalTo(dateLabel)
        }

        maxTemperatureLabel.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-sideSpace)
            make.centerY.equalTo(dateLabel)
        }

        iconImageView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.centerY.equalTo(dateLabel)
            make.right.equalTo(minTemperatureLabel.snp.left)
            make.left.equalTo(dateLabel.snp.right)
        }
    }
}
