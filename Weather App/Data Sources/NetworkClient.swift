//
//  NetworkClient.swift
//  Weather App
//
//  Created by Tim Specht on 10/22/22.
//

import Alamofire
import Combine
import Foundation

enum NetworkClientError: Error {
    case cantConstructRequest
}

typealias RequestAdapter = (URLRequest) -> URLRequest

protocol NetworkClient {
    init(requestAdapter: RequestAdapter?)
    func getData<T: Decodable>(_ url: URL, responseType: T.Type) -> AnyPublisher<T, Error>
}

class AlamofireNetworkClient: NetworkClient, Alamofire.RequestInterceptor {
    private let session: Alamofire.Session = Alamofire.Session()
    private let requestAdapter: RequestAdapter?

    required init(requestAdapter: RequestAdapter?) {
        self.requestAdapter = requestAdapter
    }

    func getData<T>(_ url: URL, responseType: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        return session.request(url, method: .get, interceptor: self)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let requestAdapter = requestAdapter {
            urlRequest = requestAdapter(urlRequest)
        }
        completion(.success(urlRequest))
    }
}
