//
//  ForecastChartView.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//
import Combine
import Charts
import SwiftUI

struct ForecastChartView: View {
    
    struct DataPoint: Identifiable, Comparable {
        var id: Float { Float(x) * y }
        
        let x: Int
        let y: Float
        
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
        
        func updateData() {
            guard let forecast = forecast else {
                return
            }
            
            chartData = forecast.forecasts.map {
                DataPoint(x: Calendar.current.component(.hour, from: $0.time),
                          y: $0.temperature.average)
            }.sorted()
            print(chartData)
        }
    }
    
    @ObservedObject var viewModel = ForecastChartView.ViewModel()

    var body: some View {
        return Chart(viewModel.chartData) {
                AreaMark(
                    x: .value("Hour", $0.x),
                    y: .value("Temperature", $0.y)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient (
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
            .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: 24)))
            // .foregroundColor(.white)
            
            .chartBackground { chartProxy in
                Color.clear
            }
            .chartXAxis(content: {
                AxisMarks { _ in
                        AxisGridLine(
                            centered: true,
                            stroke: StrokeStyle())
                              .foregroundStyle(Color.white)
                    
                        AxisValueLabel().foregroundStyle(Color.white)
                    }
            })
            .chartYAxis(content: {
                AxisMarks { _ in
                        AxisGridLine(
                            centered: true,
                            stroke: StrokeStyle())
                              .foregroundStyle(Color.white)
                    
                        AxisValueLabel().foregroundStyle(Color.white)
                    }
            })
    }
}
