//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

let view = ForecastCell(frame: CGRect(x: 0, y: 0, width: 320, height: 45))
view.backgroundColor = UIColor(red: 28/256, green: 156/256, blue: 246/256, alpha: 1)
view.dateLabel.text = "Thur"
view.maxTemperatureLabel.text = "27°"
view.minTemperatureLabel.text = "21°"
view.iconImageView.image = Asset.partlyCloudy.image
view.rangeView.layoutSubviews()
view.rangeView.setRange(start: 0, end: 1)

let currentWeatherView = CurrentWeatherCell(frame: CGRect(x: 0, y: 0, width: 320, height: 250))
currentWeatherView.temperatureLabel.text = "15°"
currentWeatherView.locationLabel.text = "Denver"
currentWeatherView.descriptionLabel.text = "Sunny"
currentWeatherView.minTemperatureLabel.text = "L:10°"
currentWeatherView.maxTemperatureLabel.text = "H:24°"

let rangeView = TemperatureRangeView(frame: CGRect(x: 0, y: 0, width: 250, height: 25))
rangeView.backgroundColor = .red
rangeView.layer.cornerRadius = 25/2
rangeView.layer.masksToBounds = true
rangeView.setRange(start: 0.1, end: 0.7)

let detailSummaryView = ForecastDetailSummaryView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
detailSummaryView.backgroundColor = .black
detailSummaryView.temperatureLabel.text = "16°"
detailSummaryView.temperatureRangeLabel.text = "H:10° L:12°"
detailSummaryView.iconImageView.image = Asset.cloudy.image.withRenderingMode(.alwaysTemplate)

let detailCell = ForecastDetailCell(frame: CGRect(x: 0, y: 0, width: 250, height: 350))
detailCell.backgroundColor = .red
detailCell.summaryView.temperatureLabel.text = "16°"
detailCell.summaryView.temperatureRangeLabel.text = "H:10° L:12°"
detailCell.summaryView.iconImageView.image = Asset.cloudy.image.withRenderingMode(.alwaysTemplate)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = detailCell
