//
//  City.swift
//  SoftexGroupTask
//
//  Created by Ivan on 17/05/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

struct Country: Codable  {
//    "Id": "CC47E518-CC99-4AB2-A6F8-00E95974721A",
//    "Time": "2016-08-08 18:20:20.9566253",
//    "Name": "Ethiopia",
//    "Image": "https://raw.githubusercontent.com/Softex-Group/task-mobile/master/Ethiopia.jpeg"
    
    let id: String
    let time: String
    let name: String
    let image: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case time = "Time"
        case name = "Name"
        case image = "Image"
    }
}
