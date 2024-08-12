//
//  CandidateTimeResponse.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class CandidateTimeResponse {
    
    // MARK: - 모임 상세 조회(시간)
    struct GetMeetingDetailTimes: Codable {
        var myVotedTimes: [String] = []
        var totalCandidateTimes: [CandidateTimeInfo] = []
        var numberOfPeople: Int = 0
    }
            
    struct CandidateTimeInfo: Codable {
        var dateTime: String = ""
        var voteCount: Int = 0
    }
}
