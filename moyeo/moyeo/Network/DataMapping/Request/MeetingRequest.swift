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
    
    struct CreateMeeting: Codable {
        var title: String = ""
        var startDate: String = ""
        var endDate: String = ""
        var startTime: String = ""
        var endTime: String = ""
        var fixedTimes: [CreateMeetingTime] = []
        var fixedPlace: CreateMeetingPlace = CreateMeetingPlace()
        var candidatePlaces: [CreateMeetingPlace] = []
        var deadline: String = ""
        
        
        struct CreateMeetingTime: Codable {
            var date: String = ""
            var time: String = ""
        }
        
        struct CreateMeetingPlace: Codable {
            var title: String = ""
            var address: String = ""
            var latitude: Double = 0.0
            var longitude: Double = 0.0
        }
    }
}
