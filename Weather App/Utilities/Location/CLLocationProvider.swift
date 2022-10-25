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

    private let geoCoder = CLGeocoder()
    private lazy var locationPublisher: CLLocationManager.LocationPublisher = {
        CLLocationManager.publishLocation(desiredAccuracy: kCLLocationAccuracyHundredMeters)
    }()

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
        return locationPublisher
            .flatMap { clLocation -> AnyPublisher<(CLPlacemark, CLLocation), Swift.Error> in // TODO: Need a weak self here
                self.reverseGeocode(location: clLocation)
                    .map { ($0, clLocation)}
                    .eraseToAnyPublisher()
            }
            .tryMap { (placemark, clLocation) in
                guard let locality = placemark.locality else {
                    throw CLLocationProvider.Error.noLocality
                }
                return Location(name: "\(locality)", latitude: Float(clLocation.coordinate.latitude), longitude: Float(clLocation.coordinate.longitude))
            }
            .eraseToAnyPublisher()
    }
}
