//
//  PlaceRequest.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class PlaceRequest {
    struct PlaceCreate: Codable {
        var title: String = ""
        var address: String = ""
        var latitude: Double = 0.0
        var longitude: Double = 0.0
    }
}
