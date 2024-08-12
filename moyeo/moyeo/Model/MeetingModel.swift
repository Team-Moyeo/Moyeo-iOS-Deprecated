//
//  MeetingResponse.swift
//  moyeo
//
//  Created by Woowon Kang on 8/10/24.
//

import Foundation

struct MeetingResponseWon {
    
    struct Meeting: Codable {
        let meetingId: Int
    }
}

struct MeetingInfo: Codable {
    let title: String
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
    let fixedTimes: [String]?
    let fixedPlace: Place?
    let candidatePlaces: [Place]?
    let deadline: String
}

struct FixedPlaceInfo: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}
