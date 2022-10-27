//
//  ForecastOverviewViewController.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import Combine
import CombineCocoa
import SnapKit
import UIKit

class ForecastOverviewViewController: UIViewController {
    private let viewModel: ForecastOverviewViewModel

    private let refreshControl = UIRefreshControl()
    internal let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var diffableDataSource = configureDataSource()

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

        viewModel.reload()
            .sink()
            .store(in: &cancellables)
    }
}

// MARK: - Data Bindings
private extension ForecastOverviewViewController {
    func configureDataSource() -> UICollectionViewDiffableDataSource<ForecastOverview.Section, ForecastOverview.Item> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
           switch item {
           case .current(let currentWeather, let minTemperature, let maxTemperature):
               let cell: CurrentWeatherCell = collectionView.dequeueReusableCell(for: indexPath)
               let cellViewModel = CurrentWeatherCellViewModel(currentWeather: currentWeather, minTemperature: minTemperature, maxTemperature: maxTemperature)
               cell.configure(with: cellViewModel)
               return cell
           case .daily(let forecast, let min, let max, _):
               let cell: ForecastCell = collectionView.dequeueReusableCell(for: indexPath)
               let cellViewModel = ForecastCellViewModel(forecast: forecast, minTemperature: min, maxTemperature: max)
               cell.configure(with: cellViewModel)
               return cell
           }
       }
    }

    func setupBindings() {
        // When the VM has new data, we want to let the DiffableDataSource now
        viewModel.dataUpdated
            // TODO: Handle errors here somehow by looking at the completion
            .sink(receiveValue: { [weak self] snapshot in
                self?.diffableDataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &cancellables)

        // When the user pulled-to-refresh, we want to let the VM now
        refreshControl.isRefreshingPublisher
            .filter { $0 }  // Only on true we want to progress
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Error> in
                guard let self = self else {
                    return Fail(error: AppError.noSelf).eraseToAnyPublisher()
                }
                return self.viewModel.reload()
            }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] success in
                self?.refreshControl.endRefreshing()
                print("Reloading finished with success? \(success)")
            })
            .store(in: &cancellables)
    }
}

// MARK: - Views
private extension ForecastOverviewViewController {
    func configureViews() {

        view.backgroundColor = Asset.lightBlueColor.color

        // Configure the collection view
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
        collectionView.register(CurrentWeatherCell.self)
        collectionView.register(ForecastCell.self)

        // Size the collection view
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        // Add the refresh control
        refreshControl.tintColor = .white
        collectionView.refreshControl = refreshControl
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

extension ForecastOverviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .daily(let selectedForecast, _, _, let allForecasts):
            // TODO: Probably time to put in a coordinator here
            let viewModel = ForecastDetailViewModelImpl(forecasts: allForecasts, initialIndex: allForecasts.firstIndex(of: selectedForecast) ?? 0)
            let viewController = ForecastDetailViewController(viewModel: viewModel)
            present(viewController, animated: true)
        default:
            break
        }
    }
}
