//
//  ForecastChartView.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Charts
import SwiftUI

class ForecastChartViewModel: ObservableObject {
    @Published private(set) var forecasts: [ForecastWeather]
    
    init(forecasts: [ForecastWeather]) {
        self.forecasts = forecasts
    }
}

struct ForecastChartView: View {
    
    @ObservedObject var viewModel: ForecastChartViewModel
    
    var body: some View {
        Chart(viewModel.forecasts) {
            LineMark(
                x: .value("Month", "test123 \($0.time)"),
                y: .value("Hours of Sunshine", 12)
            )
        }
    }
}

struct ForecastChartView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastChartView(viewModel: ForecastChartViewModel(forecasts: []))
    }
}
