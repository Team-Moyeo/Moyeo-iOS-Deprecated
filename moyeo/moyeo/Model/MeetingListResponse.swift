//
//  MeetingListResponse.swift
//  moyeo
//
//  Created by Woowon Kang on 8/5/24.
//

import Foundation

struct MeetingListResponse: Codable {
    
    struct MeetingStatus: Codable, Hashable {
        let meetingId: Int64
        let title: String
        let deadline: String
        let meetingStatus: String
    }
    
    let meetingList: [MeetingStatus]
}
