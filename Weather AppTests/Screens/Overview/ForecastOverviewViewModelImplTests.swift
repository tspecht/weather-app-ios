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
    let location = Location(name: "Test location", latitude: 123, longitude: 456)
    let session = Alamofire.Session()
    var viewModel: ForecastOverviewViewModelImpl!
    var mockDataSource: MockDataSource!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = Set<AnyCancellable>()
        mockDataSource = MockDataSource(session: session, apiKey: "test123")
        viewModel = ForecastOverviewViewModelImpl(location: location, dataSource: mockDataSource)
    }

    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }

        viewModel = nil
        mockDataSource = nil

        try super.tearDownWithError()
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

        let result = try awaitPublisherResult(viewModel.loadCurrentWeather())
        XCTAssertTrue(result)

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.current])

        let generatedData = try XCTUnwrap(mockDataSource.generatedCurrentWeather[location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .current), [.current(generatedData)])
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

        let result = try awaitPublisherResult(viewModel.loadDailyForecast())
        XCTAssertTrue(result)

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.dailyForecast])

        let generatedData = try XCTUnwrap(mockDataSource.generatedDailyForecasts[location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .dailyForecast), generatedData.map { .daily($0) })
    }

    func testLoadedBoth() throws {
        var resultSnapshot: ForecastOverview.Snapshot?
        let cancellable = viewModel.dataUpdated
            .sink(receiveCompletion: { _ in },
            receiveValue: { value in
                resultSnapshot = value
            }
        )

        let results = try awaitPublisherResults([viewModel.loadCurrentWeather(), viewModel.loadDailyForecast()])
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0])
        XCTAssertTrue(results[1])

        // awaitPublisherResult from above is doing the waiting for us as we used self.expectation. At this point, all we need to do is cancel the subscription to clean up
        cancellable.cancel()

        let snapshot = try XCTUnwrap(resultSnapshot)
        XCTAssertEqual(snapshot.sectionIdentifiers, [.current, .dailyForecast])

        let generatedCurrentWeather = try XCTUnwrap(mockDataSource.generatedCurrentWeather[location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .current), [.current(generatedCurrentWeather)])

        let generatedDailyForecasts = try XCTUnwrap(mockDataSource.generatedDailyForecasts[location])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .dailyForecast), generatedDailyForecasts.map { .daily($0) })
    }
}
