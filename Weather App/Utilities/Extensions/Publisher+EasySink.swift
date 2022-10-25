//
//  Publisher+EasySink.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine

extension Publisher {
    func sink() -> AnyCancellable {
        self.sink { _ in

        } receiveValue: { _ in

        }
    }

    func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}
