//
//  ForecastDetailSummaryView.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import UIKit
import SnapKit

class ForecastDetailSummaryView: UIView {
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        return label
    }()
    
    lazy var temperatureRangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        return label
    }()

    lazy var iconImageView: UIImageView = {
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
}
