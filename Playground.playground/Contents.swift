//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

let view = ForecastCell(frame: CGRect(x: 0, y: 0, width: 320, height: 45))
view.backgroundColor = UIColor(red: 28/256, green: 156/256, blue: 246/256, alpha: 1)
view.dateLabel.text = "Thur"
view.maxTemperatureLabel.text = "27°"
view.minTemperatureLabel.text = "21°"
view.iconImageView.image = Asset.clear.image

let currentWeatherView = CurrentWeatherCell(frame: CGRect(x: 0, y: 0, width: 320, height: 250))
currentWeatherView.temperatureLabel.text = "15°"
currentWeatherView.locationLabel.text = "Denver"
currentWeatherView.descriptionLabel.text = "Sunny"
currentWeatherView.minTemperatureLabel.text = "L:10°"
currentWeatherView.maxTemperatureLabel.text = "H:24°"

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view
