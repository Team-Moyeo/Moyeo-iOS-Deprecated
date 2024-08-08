//
//  MeetingListResponse.swift
//  moyeo
//
//  Created by Woowon Kang on 8/5/24.
//

import Foundation

struct MeetingListResponse {
    
    struct MeetingStatus: Codable, Hashable {
        let meetingId: Int64
        let title: String
        let deadline: String
    }
}
