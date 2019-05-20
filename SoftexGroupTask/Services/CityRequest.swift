//
//  CityRequest.swift
//  SoftexGroupTask
//
//  Created by Ivan on 18/05/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

class CountryRequest: APIRequest {
    var method = RequestType.GET
    var path = "Softex-Group/task-mobile/master/test.json"
    var parameters = [String: String]()
    
    init(_ name: String = "") {
        parameters["name"] = name
    }
}
