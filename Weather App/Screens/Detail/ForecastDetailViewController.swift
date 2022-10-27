//
//  ForecastDetailViewController.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import UIKit

class ForecastDetailViewController: UIViewController {

    private let viewModel: ForecastDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    internal let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var diffableDataSource = configureDataSource()

    init(viewModel: ForecastDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setupBindings()
    }
}

// MARK: - Private
private extension ForecastDetailViewController {

    func setupBindings() {
        // When the VM has new data, we want to let the DiffableDataSource now
        viewModel.dataUpdated
            // TODO: Handle errors here somehow by looking at the completion
            .sink(receiveValue: { [weak self] snapshot in
                self?.diffableDataSource.apply(snapshot, animatingDifferences: false)
            })
            .store(in: &cancellables)
    }

    func configureViews() {
        view.backgroundColor = Asset.superDarkGray.color

        // Configure the collection view
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
        collectionView.register(ForecastDetailChartCollectionCell.self)
        collectionView.register(ForecastDetailSummaryCell.self)

        // Size the collection view
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    func configureDataSource() -> UICollectionViewDiffableDataSource<ForecastDetail.Section, ForecastDetail.Item> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
           switch item {
           case .summary(let dayForecast, let selectedForecast):
               let cell: ForecastDetailSummaryCell = collectionView.dequeueReusableCell(for: indexPath)
               let viewModel = ForecastDetailSummaryCellViewModel(
                    dayForecast: dayForecast,
                    mode: selectedForecast != nil ? .hidden : (dayForecast.isToday ? .today : .forecast)
               )
               cell.configure(with: viewModel)
               return cell
           case .charts(let dayForecasts):
               let cell: ForecastDetailChartCollectionCell = collectionView.dequeueReusableCell(for: indexPath)

               // TODO: We might want to keep this around as a property
               let cellProvider: ForecastDetailChartCollectionViewModel.DataSource.CellProvider = { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
                   guard let self = self else {
                       return nil
                   }
                   switch item {
                   case .chart(let dayForecast):
                       let cell: ForecastDetailChartCell = collectionView.dequeueReusableCell(for: indexPath)
                       let viewModel = ForecastDetailChartCellViewModel(forecast: dayForecast)
                       cell.configure(with: viewModel)
                       return cell
                   }
               }

               let viewModel = ForecastDetailChartCollectionViewModel(forecasts: dayForecasts, initialSelectedIndex: self.viewModel.initialIndex, cellProvider: cellProvider)

               viewModel.selectedForecastChanged
                   .receive(on: DispatchQueue.main)
                   .compactMap { $0 }
                   .sink { selectedForecast in
                       self.viewModel.select(activeForecast: selectedForecast)
                   }
                   .store(in: &self.cancellables)
//               viewModel.selectedForecastWeather
//                   .receive(on: DispatchQueue.main)
//                   .sink { [weak self] selectedForecastWeather in
//                       self?.viewModel.select(forecastWeather: selectedForecastWeather)
//                   }
//                   .store(in: &self.cancellables)
               cell.configure(with: viewModel)
               return cell
           }
       }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ForecastDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = diffableDataSource.itemIdentifier(for: indexPath)
        switch item {
        case .summary:
            return CGSize(width: collectionView.bounds.size.width - 2 * 16, height: 91)
        case .charts:
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.width * 0.7)
        case .none:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch ForecastDetail.Section(rawValue: section) {
        case .detail:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        case .charts:
            return .zero
        default:
            return .zero
        }
    }
}
