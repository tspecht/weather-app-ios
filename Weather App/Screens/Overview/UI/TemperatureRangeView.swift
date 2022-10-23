//
//  TemperatureRangeView.swift
//  Weather App
//
//  Created by Tim Specht on 10/23/22.
//

import UIKit

class TemperatureRangeView: UIView {

    var highlightColor: UIColor = .white

    private(set) var start: Float = 0
    private(set) var end: Float = 1

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = bounds.size.height / 2
        layer.cornerRadius = cornerRadius
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Draw the actual progress now
        let startX = rect.size.width * CGFloat(start)
        let endX = rect.size.width * CGFloat(end)
        let path = UIBezierPath(roundedRect: CGRect(x: startX, y: 0, width: endX - startX, height: rect.size.height), cornerRadius: bounds.size.height / 2)

        // Create the gradient
        // TODO: Technically the color gradient here should be relative to the max temperature range in total possible (e.g. if the max range for today is up to 60deg, the max color should be yellow and not bright red)
        guard let gradient = CGGradient(colorsSpace: nil, colors: [UIColor.systemGreen.cgColor, UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor] as CFArray, locations: nil),
              let context = UIGraphicsGetCurrentContext() else { return }

        // Draw the graph and apply the gradient
        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: frame.width, y: frame.height), options: [])
        context.restoreGState()
    }

    func setRange(start: Float, end: Float) {
        self.start = start
        self.end = end
        setNeedsDisplay()
    }
}
