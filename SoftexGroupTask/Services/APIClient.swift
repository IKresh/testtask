//
//  APIClient.swift
//  SoftexGroupTask
//
//  Created by Ivan on 18/05/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation
import RxSwift

class APIClient {
    private let baseURL = URL(string: "https://raw.githubusercontent.com/")!
    
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { [unowned self] observer in
            let request = apiRequest.request(with: self.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
