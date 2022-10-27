//
//  DateFormatter+Convenience.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import Foundation

extension DateFormatter {
    convenience init(format: String, timezone: TimeZone? = nil) {
        self.init()
        self.dateFormat = format
        self.timeZone = timezone
    }

    convenience init(dateStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}
