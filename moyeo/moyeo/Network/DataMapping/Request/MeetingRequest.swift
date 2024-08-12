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
}
