//
//  MeetingResponse.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class MeetingResponse: ObservableObject {
    
    struct DeleteMeeting: Codable {
        var meetingId: Int = 0
    }
}
