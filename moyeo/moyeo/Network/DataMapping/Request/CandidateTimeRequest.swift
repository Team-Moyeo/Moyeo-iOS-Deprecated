//
//  CandidateTimeRequest.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class CandidateTimeRequest {
    
    // MARK: - 모임 상세 조회(시간)
    struct GetMeetingDetailTimes: Codable {
        var meetingId: Int = 0
    }
}
