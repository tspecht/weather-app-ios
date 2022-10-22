//
//  Array+Utilities.swift
//  Weather App
//
//  Created by Tim Specht on 10/22/22.
//

import Foundation

extension Array {
    var middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }
}
