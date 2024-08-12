//
//  MeetingRequest.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class MeetingRequest {
    struct VoteUpdate: Codable {
        var candidateTimes: [String] = []
        var candidatePlaces: [String] = []
    }
    
    struct FixMeeting: Codable {
        var fixedTimes: [String] = []
        var fixedPlace: FixPlaceInfo = FixPlaceInfo()
    }
    
    struct FixPlaceInfo: Codable {
        var title: String = ""
        var address: String = ""
        var latitude: Double = 0.0
        var longitude: Double = 0.0
    }
}
