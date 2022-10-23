//
//  ForecastOverviewViewControllerTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/22/22.
//

import Alamofire
import Combine
import XCTest
@testable import Weather_App

class ForecastOverviewViewControllerTests: XCTestCase {
//    class MockDiffableDataSource<Section: Hashable, Item: Hashable>: UICollectionViewDiffableDataSource<Section, Item> {
//
//        var applyCalled = false
//        var lastAppliedSnapshot: NSDiffableDataSourceSnapshot<Section, Item>
//
//        override nonisolated func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, animatingDifferences: Bool = true) async {
//
//        }
//    }
//
    class MockViewModel: ForecastOverviewViewModel {
        var dataUpdated: PassthroughSubject<Weather_App.ForecastOverview.Snapshot, Weather_App.DataSourceError> = PassthroughSubject()

        var calledLoadCurrentWeather = false
        var calledLoadDailyForecast = false

        required init(location: Weather_App.Location, dataSource: Weather_App.DataSource) {

        }

        func loadCurrentWeather() -> AnyPublisher<Bool, Weather_App.DataSourceError> {
            calledLoadCurrentWeather = true
            return Just(true)
                .setFailureType(to: DataSourceError.self)
                .eraseToAnyPublisher()
        }

        func loadDailyForecast() -> AnyPublisher<Bool, Weather_App.DataSourceError> {
            calledLoadDailyForecast = true
            return Just(true)
                .setFailureType(to: DataSourceError.self)
                .eraseToAnyPublisher()
        }

    }

    let session = Alamofire.Session()
    var mockViewModel: MockViewModel!
    var viewController: ForecastOverviewViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockViewModel = MockViewModel(location: Fakes.location, dataSource: MockDataSource(networkClient: MockNetworkClient()))
        viewController = ForecastOverviewViewController(viewModel: mockViewModel)
    }

    override func tearDownWithError() throws {
        viewController = nil
        mockViewModel = nil

        try super.tearDownWithError()
    }

    func testLoadsDataOnViewDidLoad() {
        XCTAssertFalse(mockViewModel.calledLoadDailyForecast)
        XCTAssertFalse(mockViewModel.calledLoadCurrentWeather)

        _ = viewController.view  // To make sure the view gets loaded

        XCTAssertTrue(mockViewModel.calledLoadDailyForecast)
        XCTAssertTrue(mockViewModel.calledLoadCurrentWeather)
    }

    func testReloadsCollectionViewAfterDataUpdated() throws {
        _ = viewController.view  // To make sure the view gets loaded
        XCTAssertEqual(viewController.collectionView.numberOfSections, 0)

        var snapshot = ForecastOverview.Snapshot()

        snapshot.appendSections([.current, .dailyForecast])
        snapshot.appendItems([.current(Fakes.currentWeather, 1.5, 2.2)], toSection: .current)
        snapshot.appendItems([.daily(Fakes.dayForecast(), 2, 100)], toSection: .dailyForecast)

        mockViewModel.dataUpdated.send(snapshot)

        // Assert general data
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        XCTAssertEqual(viewController.collectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(viewController.collectionView.numberOfItems(inSection: 1), 1)

        // Make sure the cells are alright
        let currentCell = try XCTUnwrap(viewController.collectionView.dataSource?.collectionView(viewController.collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as? CurrentWeatherCell)
        XCTAssertEqual(currentCell.locationLabel.text, Fakes.location.name)
        XCTAssertEqual(currentCell.temperatureLabel.text, "123°")
        XCTAssertEqual(currentCell.maxTemperatureLabel.text, "H:2°")
        XCTAssertEqual(currentCell.minTemperatureLabel.text, "L:1°")
        XCTAssertEqual(currentCell.descriptionLabel.text, "clear skys")

        let forecastCell = try XCTUnwrap(viewController.collectionView.dataSource?.collectionView(viewController.collectionView, cellForItemAt: IndexPath(row: 0, section: 1)) as? ForecastCell)
        XCTAssertEqual(forecastCell.maxTemperatureLabel.text, "23°")
        XCTAssertEqual(forecastCell.minTemperatureLabel.text, "21°")
        XCTAssertEqual(forecastCell.iconImageView.image, Asset.clear.image)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        XCTAssertEqual(forecastCell.dateLabel.text, dateFormatter.string(from: Date()))
        XCTAssertEqual(forecastCell.rangeView.start, 0.19139999)
        XCTAssertEqual(forecastCell.rangeView.end, 0.2364)
    }
}
