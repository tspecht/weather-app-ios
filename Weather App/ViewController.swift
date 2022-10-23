//
//  ViewController.swift
//  Weather App
//
//  Created by Tim Specht on 10/20/22.
//

import UIKit
import Combine
import SnapKit
import Alamofire

class ViewController: UIViewController {

    private lazy var dataSource: DataSource = {
        let monitor = ClosureEventMonitor()
        monitor.requestDidCompleteTaskWithError = { (request, _, _) in
            debugPrint(request)

        }
        monitor.dataTaskDidReceiveData = { (_, _, data) in
            debugPrint(String(data: data, encoding: .utf8)!)
        }

        let session = Alamofire.Session(configuration: .default,
                                        eventMonitors: [monitor])
        let networkClient = AlamofireNetworkClient { request in
            var request = request
            if let url = request.url,
               let queryComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var queryComponents = queryComponents
                queryComponents.queryItems?.append(URLQueryItem(name: "appid", value: "a8e5bcdb61bbbb92a1aff8df862d2668"))
                request.url = queryComponents.url
            }

            return request
        }
        let dataSource = OpenMeteoDataSource(networkClient: networkClient)
        return dataSource
    }()

    private lazy var viewModel: ForecastOverviewViewModel = {
       return ForecastOverviewViewModelImpl(location: Location(name: "Denver", latitude: 39.7392, longitude: -104.9849), dataSource: dataSource)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let viewController = ForecastOverviewViewController(viewModel: viewModel)

        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

}
