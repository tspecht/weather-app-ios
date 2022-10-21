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

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // TODO: Move this to helper function
    // lazy var dataSource = configureDataSource()

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource = {
        let dataSource = UICollectionViewDiffableDataSource<ForecastOverview.Section, ForecastOverview.Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .current(let currentWeather):
                let cell: CurrentWeatherCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.temperatureLabel.text = "\(currentWeather.temperature.current)°"
                cell.feelsLikeLabel.text = "Feels like \(currentWeather.temperature.feelsLike)°"
                cell.locationLabel.text = currentWeather.location.name
                return cell
            default:
                return nil
            }
        }
        return dataSource
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
        viewModel.loadDailyForecast()
    }
}

// MARK: - Data Bindings
private extension ForecastOverviewViewController {
    func setupBindings() {
        viewModel.dataUpdated
            .sink { [weak self] _ in
                // TODO: Handle errors here somehow
            } receiveValue: { [weak self] snapshot in
                self?.diffableDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Views
private extension ForecastOverviewViewController {
    func configureViews() {

        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.reuseIdentifier)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ForecastOverviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: UIScreen.main.bounds.size.width, height: 150)
        default:
            return .zero
        }
    }
}
