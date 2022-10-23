//
//  DateFormatter+Convenience.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
