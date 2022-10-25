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

    internal let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // TODO: Move this to helper function
    // lazy var dataSource = configureDataSource()

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource = {
        let dataSource = UICollectionViewDiffableDataSource<ForecastOverview.Section, ForecastOverview.Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .current(let currentWeather, let minTemperature, let maxTemperature):
                let cell: CurrentWeatherCell = collectionView.dequeueReusableCell(for: indexPath)
                let cellViewModel = CurrentWeatherCellViewModel(currentWeather: currentWeather, minTemperature: minTemperature, maxTemperature: maxTemperature)
                cell.configure(with: cellViewModel)
                return cell
            case .daily(let forecast, let min, let max):
                let cell: ForecastCell = collectionView.dequeueReusableCell(for: indexPath)
                let cellViewModel = ForecastCellViewModel(forecast: forecast, minTemperature: min, maxTemperature: max)
                cell.configure(with: cellViewModel)
                return cell
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

        // TODO: Figure out if there is a way to have an empty sink
        viewModel.reload()
            .sink { _ in

            } receiveValue: { _ in

            }
            .store(in: &cancellables)
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

        view.backgroundColor = Asset.lightBlueColor.color

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
        collectionView.register(CurrentWeatherCell.self)
        collectionView.register(ForecastCell.self)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}

// TODO: THe below is super ugly, has to be possible to do this nicer
// MARK: - UICollectionViewDelegateFlowLayout
extension ForecastOverviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch ForecastOverview.Section(rawValue: indexPath.section) {
        case .current:
            return CGSize(width: collectionView.bounds.size.width, height: 175)
        case .dailyForecast:
            return CGSize(width: collectionView.bounds.size.width - 2 * 32, height: 50)
        case .none:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch ForecastOverview.Section(rawValue: section) {
        case .dailyForecast:
            return UIEdgeInsets(top: 32, left: 32, bottom: 8, right: 32)
        default:
            return .zero
        }
    }
}
