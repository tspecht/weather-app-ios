//
//  ForecastChartView.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//
import Combine
import Charts
import SwiftUI
import GameplayKit

struct ForecastChartView: View {

    struct DataPoint: Identifiable, Comparable {
        var id: Float { Float(x) * y }

        let x: Int
        let y: Float
        let iconImage: UIImage

        static func < (lhs: DataPoint, rhs: DataPoint) -> Bool {
            return lhs.x < rhs.x
        }
    }

    // TODO: This definitelz needs unit tests
    class ViewModel: ObservableObject {
        var forecast: DayForecast? {
            didSet {
                updateData()
            }
        }
        @Published var chartData: [DataPoint] = []
        @Published var selectedIndex: Int?

        var xValues: [Int] {
            chartData.map { $0.x }
        }

        var yValues: [Float] {
            chartData.map { $0.y }
        }

        var xLabels: [Int] {
            [0, 6, 12, 18, 24]
        }

        var yLabels: [Float] {
            let yValues = self.yValues
            guard let min = yValues.min(),
                  let max = yValues.max() else {
                return []
            }

            let numLabels: Float = 11
            let range = max - min
            let minRange = min - (range / 3)
            let maxRange = max + (range / 3)
            return  Array(stride(from: minRange, to: maxRange, by: yStride))
        }

        var yStride: Float {
            let yValues = self.yValues
            guard let min = yValues.min(),
                  let max = yValues.max() else {
                return 0
            }

            let numLabels: Float = 11
            let range = max - min
            let minRange = min - (range / 3)
            let maxRange = max + (range / 3)
            return (maxRange - minRange) / numLabels
        }

        var minYLabel: Float { yLabels.min() ?? 0 }
        var maxYLabel: Float { yLabels.max() ?? 0 }

        var minY: Float { yValues.min() ?? 0 }
        var maxY: Float { yValues.max() ?? 0 }

        var minX: Int { xValues.min() ?? 0 }
        var maxX: Int { xValues.max() ?? 0 }

        var xForMaxY: Int { xValues[yValues.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0] }
        var xForMinY: Int { xValues[yValues.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0] }

        func updateData() {
            guard let forecast = forecast else {
                return
            }

            chartData = forecast.forecasts.map {
                DataPoint(x: Calendar.current.component(.hour, from: $0.time),
                          y: $0.temperature.average,
                          iconImage: $0.description.iconImageAsset.image)
            }.sorted()
        }
    }

    @ObservedObject var viewModel = ForecastChartView.ViewModel()

    var body: some View {
        let whiteOpaque = Color.white.opacity(0.5)

        return VStack {
            Spacer(minLength: 10)
            Chart(viewModel.chartData) {
                AreaMark(
                    x: .value("Hour", $0.x),
                    yStart: .value("Temperature", $0.y),
                    yEnd: .value("end", viewModel.minYLabel)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(uiColor: Asset.turqoise.color).opacity(0.5),
                            Color.blue.opacity(0.4)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                ))

                LineMark(
                    x: .value("Hour", $0.x),
                    y: .value("Temperature", $0.y)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color(uiColor: Asset.turqoise.color))
                .lineStyle(StrokeStyle(lineWidth: 5))

                if let selectedIndex = viewModel.selectedIndex,
                   let selectedDataPoint = viewModel.chartData[safe: selectedIndex] {
                    RuleMark(x: .value("Rule", selectedDataPoint.x), yStart: -32)
                        .foregroundStyle(Color.white)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                        .annotation(position: .top) {
                            HStack {
                                Image(uiImage: selectedDataPoint.iconImage)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .aspectRatio(contentMode: .fit)
                                    
                                Text("\(Int(selectedDataPoint.y))°")
                                    .foregroundColor(.white)
                                    .font(.system(size: 32, weight: .bold))
                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                        }

                    PointMark(x: .value("Selected", selectedDataPoint.x), y: .value("Selected", selectedDataPoint.y))
                        .foregroundStyle(Color.white)
                }

                // H point
                PointMark(x: .value("Top", viewModel.xForMaxY), y: .value("Top", viewModel.maxY))
                    .foregroundStyle(Color.white)
                    .annotation(position: .top, alignment: .center) {
                            Text("H")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                    }

                // L Point
                PointMark(x: .value("Bottom", viewModel.xForMinY), y: .value("Bottom", viewModel.minY))
                    .foregroundStyle(Color.white)
                    .annotation(position: .top, alignment: .center) {
                            Text("L")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                    }
            }
            .chartBackground { _ in
                Color.clear
            }
            .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: viewModel.minX, upper: viewModel.maxX)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: viewModel.minYLabel, upper: viewModel.maxYLabel)))
            .chartXAxis(content: {
                // Bottom marks containing the hour of the day
                AxisMarks(values: .stride(by: 6)) { value in
                    AxisGridLine(
                        centered: true,
                        stroke: StrokeStyle(dash: [5]))
                    .foregroundStyle(whiteOpaque.opacity(0.15))

                    AxisValueLabel {
                        Text("\(value.as(Int.self) ?? 0)")
                            .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                    }
                    .foregroundStyle(whiteOpaque)
                    .font(.system(size: 14, weight: .heavy))
                }

                // Top marks containing the weather values
                AxisMarks(position: .top, values: .stride(by: 2)) { value in
                    AxisValueLabel(verticalSpacing: 8) {
                        Image(uiImage: viewModel.chartData[value.index].iconImage)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .aspectRatio(contentMode: .fit)
                    }
                    .foregroundStyle(whiteOpaque)
                }
            })
            .chartYAxis(content: {
                AxisMarks(values: viewModel.yLabels) { value in
                    AxisGridLine(
                        centered: true,
                        stroke: StrokeStyle())
                    .foregroundStyle(whiteOpaque.opacity(0.15))

                    AxisValueLabel {
                        Text("\(Int(value.as(Float.self) ?? 0))°")
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 16))
                    }
                    .foregroundStyle(whiteOpaque)
                    .font(.system(size: 14, weight: .heavy))
                }
            })
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(DragGesture()
                            .onChanged { value in
                                // find start and end positions of the drag
                                let start = geo[proxy.plotAreaFrame].origin.x
                                let xCurrent = value.location.x - start

                                viewModel.selectedIndex = Int((xCurrent / proxy.plotAreaSize.width) * CGFloat(viewModel.xValues.count))

                            }.onEnded({ _ in
                                viewModel.selectedIndex = nil
                            }))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ForecastChartView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ForecastChartView.ViewModel()
        let icons = [
            Asset.clear.image,
            Asset.partlyCloudy.image,
            Asset.snow.image,
            Asset.rain.image
        ]
        let random = GKRandomSource()
        let dice3d6 = GKGaussianDistribution(randomSource: random, lowestValue: 5, highestValue: 25)

        viewModel.chartData = (0...24).map {
            ForecastChartView.DataPoint(x: $0, y: Float(dice3d6.nextInt()), iconImage: icons.randomElement()!)
        }
        return ZStack {
            Color(Asset.superDarkGray.color).edgesIgnoringSafeArea(.all)
            ForecastChartView(viewModel: viewModel)
                .frame(height: 350.0)
        }
    }
}
