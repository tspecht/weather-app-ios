//
//  UIView+Subviews.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}
