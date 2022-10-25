//
//  Reusable.swift
//  Weather App
//
//  Created by Tim Specht on 10/21/22.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String { "\(type(of: Self.self))" }
}
