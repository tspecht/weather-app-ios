//
//  ForecastDetailViewController.swift
//  Weather App
//
//  Created by Tim Specht on 10/25/22.
//

import Combine
import UIKit

class ForecastDetailViewController: UIViewController {
    
    private let viewModel: ForecastDetailViewModel
    
    init(viewModel: ForecastDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
}

// MARK: - Private
private extension ForecastDetailViewController {
    func configureViews() {
        view.backgroundColor = .red
    }
}
