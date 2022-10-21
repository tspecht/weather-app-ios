//
//  UICollectionView+Typecasting.swift
//  Weather App
//
//  Created by Tim Specht on 10/21/22.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: Reusable>(for indexPath: IndexPath) -> T {
        let dequeuedCell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath)
        guard let cell = dequeuedCell as? T else {
            fatalError("Got unexpected cell of type \(type(of: dequeuedCell)), expected \(T.self)")
        }
        return cell
    }
}
