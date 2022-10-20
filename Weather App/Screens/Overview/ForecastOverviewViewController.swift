//
//  ForecastOverviewViewController.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Combine
import SnapKit
import UIKit

class ForecastOverviewViewController: UIViewController {
    private let viewModel: ForecastOverviewViewModel

    private lazy var headerView: CurrentWeatherView = {
       return CurrentWeatherView()
    }()

    private var cancellables = Set<AnyCancellable>()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: ForecastOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()

        configureViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        viewModel.loadCurrentWeather()
    }
}

// MARK: - Data Bindings
private extension ForecastOverviewViewController {
    func setupBindings() {
        viewModel.currentWeather
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error loading weather: \(error)")
                default: break
                }
            } receiveValue: { currentWeather in
                self.headerView.locationLabel.text = currentWeather.location.name
                self.headerView.temperatureLabel.text = "\(currentWeather.temperature.current) (Feels like \(currentWeather.temperature.feelsLike)"
            }
            .store(in: &cancellables)
    }
}

// MARK: - Views
private extension ForecastOverviewViewController {
    func configureViews() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(150)
        }
    }
}
