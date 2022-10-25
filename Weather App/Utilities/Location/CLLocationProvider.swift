//
//  CLLocationProvider.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import CoreLocation
import Combine

// TODO: Figure out how to best unit test this
class CLLocationProvider: LocationProvider {

    enum Error: Swift.Error {
        case couldntReverseGeocodeLocation
        case noLocality
    }

    private var cancellables = Set<AnyCancellable>()
    private let geoCoder = CLGeocoder()
    // We need to keep the location manager running internally so we keep updating as the user moves. Only when requested we return the latest value thought
    private let currentLocationValueSubject = CurrentValueSubject<Location?, Swift.Error>(nil)

    init() {
        CLLocationManager.publishLocation(desiredAccuracy: kCLLocationAccuracyKilometer)
            .flatMap { clLocation -> AnyPublisher<(CLPlacemark, CLLocation), Swift.Error> in // TODO: Need a weak self here
                self.reverseGeocode(location: clLocation)
                    .map { ($0, clLocation)}
                    .eraseToAnyPublisher()
            }
            .tryMap { (placemark, clLocation) -> Location in
                guard let locality = placemark.locality else {
                    throw CLLocationProvider.Error.noLocality
                }
                return Location(name: "\(locality)", latitude: Float(clLocation.coordinate.latitude), longitude: Float(clLocation.coordinate.longitude))
            }
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] location in
                self?.currentLocationValueSubject.send(location)
            })
            .store(in: &cancellables)
    }

    private func reverseGeocode(location: CLLocation) -> AnyPublisher<CLPlacemark, Swift.Error> {
        let geoCoder = self.geoCoder
        return Future { [weak geoCoder] promise in
            geoCoder?.reverseGeocodeLocation(location, completionHandler: { places, error in
                if let error = error {
                    promise(Result.failure(error))
                } else {
                    guard let place = places?.first else {
                        promise(Result.failure(CLLocationProvider.Error.couldntReverseGeocodeLocation))
                        return
                    }
                    promise(Result.success(place))
                }
            })

        }.eraseToAnyPublisher()
    }

    func location() -> AnyPublisher<Location, Swift.Error> {
        return currentLocationValueSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
