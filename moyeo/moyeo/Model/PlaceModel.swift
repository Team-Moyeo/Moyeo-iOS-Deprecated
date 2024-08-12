//
//  PlaceModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/6/24.
//

import SwiftUI

struct SearchResponse: Codable {
    let items: [PlaceInfo]
}

struct PlaceInfo: Codable {
    let title: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}

struct Place: Identifiable, Codable{
    var id = UUID()
    let name: String
    let roadAddress: String
    let latitude: Double
    let longitude: Double
    let memberId: String
    let meetingId: String
    
    init(id: UUID = UUID(), name: String, roadAddress: String,
         latitude: Double, longitude: Double, memberId: String, meetingId: String) {
        self.id = id
        self.name = name
        self.roadAddress = roadAddress
        self.latitude = latitude
        self.longitude = longitude
        self.memberId = memberId
        self.meetingId = meetingId
    }
}
