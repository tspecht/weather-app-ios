//
//  ForecastDetailChartCollectionCell.swift
//  Weather App
//
//  Created by Tim Specht on 10/27/22.
//

import Combine
import UIKit
import SnapKit

struct ForecastDetailChartCollectionViewModel {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Item: Hashable {
        case chart(DayForecast)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .chart(let dayForecast):
                hasher.combine(dayForecast.date)
            }
        }
    }

    enum Section: Int {
        case chart
    }

    let initialSelectedIndex: Int
    let cellProvider: DataSource.CellProvider
    let snapshot: Snapshot
    let selectedForecastChanged = PassthroughSubject<DayForecast?, Never>()

    init(forecasts: [DayForecast], initialSelectedIndex: Int, cellProvider: @escaping DataSource.CellProvider) {
        self.cellProvider = cellProvider
        self.initialSelectedIndex = initialSelectedIndex

        var snapshot = Snapshot()
        snapshot.appendSections([.chart])
        snapshot.appendItems(forecasts.map { .chart($0) }, toSection: .chart)
        self.snapshot = snapshot
    }
}

class ForecastDetailChartCollectionCell: UICollectionViewCell, Reusable {
    private var viewModel: ForecastDetailChartCollectionViewModel?
    private var dataSource: ForecastDetailChartCollectionViewModel.DataSource?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(ForecastDetailChartCell.self)

//        collectionView.gestureRecognizers?.forEach({ gestureRecognizer in
//            guard gestureRecognizer is UIPanGestureRecognizer else {
//                return
//            }
//            (gestureRecognizer as? UIPanGestureRecognizer)?.allowedScrollTypesMask = .continuous
//        })

        return collectionView
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
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    // TODO: Need to include scroll to default item here
    func configure(with viewModel: ForecastDetailChartCollectionViewModel) {
        let dataSource = ForecastDetailChartCollectionViewModel.DataSource(collectionView: collectionView, cellProvider: viewModel.cellProvider)
        self.dataSource = dataSource
        self.viewModel = viewModel

        collectionView.dataSource = dataSource
        dataSource.apply(viewModel.snapshot) { [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(row: viewModel.initialSelectedIndex, section: 0), at: .left, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ForecastDetailChartCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else {
            return .zero
        }
        switch item {
        case .chart:
            return CGSize(width: collectionView.bounds.size.width - 2 * 8, height: collectionView.bounds.size.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}

// MARK: - UIScrollViewDelegate
extension ForecastDetailChartCollectionCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.size.width / 2, y: 0)),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            viewModel?.selectedForecastChanged.send(nil)
            return
        }

        switch item {
        case .chart(let forecast):
            viewModel?.selectedForecastChanged.send(forecast)
        }
    }
}
