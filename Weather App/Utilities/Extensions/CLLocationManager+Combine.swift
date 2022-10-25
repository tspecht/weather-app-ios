//
//  CLLocationManager+Combine.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Foundation
import Combine
import CoreLocation

extension CLLocationManager {
    public static func publishLocation(desiredAccuracy: CLLocationAccuracy) -> LocationPublisher {
        return .init(desiredAccuracy: desiredAccuracy)
    }

    public struct LocationPublisher: Publisher {
        public typealias Output = CLLocation
        public typealias Failure = Never

        private let desiredAccuracy: CLLocationAccuracy
        init(desiredAccuracy: CLLocationAccuracy) {
            self.desiredAccuracy = desiredAccuracy
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LocationSubscription(subscriber: subscriber, desiredAccuracy: desiredAccuracy)
            subscriber.receive(subscription: subscription)
        }

        final class LocationSubscription<S: Subscriber>: NSObject, CLLocationManagerDelegate, Subscription where S.Input == Output, S.Failure == Failure {
            var subscriber: S
            var locationManager: CLLocationManager

            init(subscriber: S, desiredAccuracy: CLLocationAccuracy) {
                self.subscriber = subscriber
                self.locationManager = CLLocationManager()
                self.locationManager.desiredAccuracy = desiredAccuracy
                super.init()
                locationManager.delegate = self
            }

            func request(_ demand: Subscribers.Demand) {
                locationManager.startUpdatingLocation()
                locationManager.requestWhenInUseAuthorization()
            }

            func cancel() {
                locationManager.stopUpdatingLocation()
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                for location in locations {
                    _ = subscriber.receive(location)
                }
            }
        }
    }
}
