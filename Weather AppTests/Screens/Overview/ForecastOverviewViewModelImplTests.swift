//
//  ForecastOverviewViewModelImplTests.swift
//  Weather AppTests
//
//  Created by Tim Specht on 10/21/22.
//

import Alamofire
import Combine
import XCTest
@testable import Weather_App

class ForecastOverviewViewModelImplTests: XCTestCase {
    let session = Alamofire.Session()
    var viewModel: ForecastOverviewViewModelImpl!
    var mockDataSource: MockDataSource!
    var mockLocationProvider: MockLocationProvider!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = Set<AnyCancellable>()
        mockDataSource = MockDataSource(networkClient: MockNetworkClient())
        mockLocationProvider = MockLocationProvider(fakeLocation: Fakes.location)
        viewModel = ForecastOverviewViewModelImpl(locationProvider: mockLocationProvider, dataSource: mockDataSource)
    }

    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }

        viewModel = nil
        mockDataSource = nil

        try super.tearDownWithError()
    }

    func testReload() throws {
        let fakeLocation = Location(name: "fake location for testReload()", latitude: 12, longitude: 345)
        mockLocationProvider.fakeLocation = fakeLocation

        let result = try awaitPublisherResult(viewModel.reload())
        XCTAssertTrue(result)

        // Make sure both data source endpoints were called
        XCTAssertNotNil(mockDataSource.generatedCurrentWeather[fakeLocation])
        XCTAssertNotNil(mockDataSource.generatedDailyForecasts[fakeLocation])
    }

    func testLoadCurrentWeather() throws {
        let expectation = self.expectation(description: "Awaiting updated data source")

        var resultSnapshot: ForecastOverview.Snapshot?
        let cancellable = viewModel.dataUpdated
            .sink(receiveCompletion: { _ in },
            receiveValue: { value in
                resultSnapshot = value
                expectation.fulfill()
            }
        )

        let result = try awaitPublisherResult(viewModel.loadCurrentWeather(for: Fakes.location))
        XCTAssertTrue(result)

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.current])

        let generatedData = try XCTUnwrap(mockDataSource.generatedCurrentWeather[Fakes.location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .current), [.current(generatedData, nil, nil)])
    }

    func testLoadDailyForecast() throws {
        let expectation = self.expectation(description: "Awaiting updated data source")

        var resultSnapshot: ForecastOverview.Snapshot?
        let cancellable = viewModel.dataUpdated
            .sink(receiveCompletion: { _ in },
            receiveValue: { value in
                resultSnapshot = value
                expectation.fulfill()
            }
        )

        let result = try awaitPublisherResult(viewModel.loadDailyForecast(for: Fakes.location))
        XCTAssertTrue(result)

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.dailyForecast])

        let generatedData = try XCTUnwrap(mockDataSource.generatedDailyForecasts[Fakes.location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .dailyForecast), generatedData.map { .daily($0, 21.14, 23.64) })
    }

    func testLoadedBoth() throws {
        var resultSnapshot: ForecastOverview.Snapshot?
        let cancellable = viewModel.dataUpdated
            .sink(receiveCompletion: { _ in },
            receiveValue: { value in
                resultSnapshot = value
            }
        )

        let results = try awaitPublisherResults([viewModel.loadCurrentWeather(for: Fakes.location), viewModel.loadDailyForecast(for: Fakes.location)])
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0])
        XCTAssertTrue(results[1])

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.current, .dailyForecast])

        let generatedCurrentWeather = try XCTUnwrap(mockDataSource.generatedCurrentWeather[Fakes.location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .current), [.current(generatedCurrentWeather, 21.14, 23.64)])

        let generatedDailyForecasts = try XCTUnwrap(mockDataSource.generatedDailyForecasts[Fakes.location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .dailyForecast), generatedDailyForecasts.map { .daily($0, 21.14, 23.64) })
    }
}
