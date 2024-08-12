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
    
    struct JoinWithInviteCode: Codable {
        var meetingId: Int = 0
    }
    
    struct GetInviteCode: Codable {
        var inviteCode: String = ""
    }
    
    struct GetMeetingDetail: Codable {
        var title: String = ""
        var myRole: Role = Role.PARTICIPANTS
        var startDate: String = ""
        var endDate: String = ""
        var startTime: String = ""
        var endTime: String = ""
        var deadline: String = ""
        var numberOfPeople: Int = 0
        
        enum Role: String, Codable {
            case OWNER
            case PARTICIPANTS
        }
    }
    
    struct VoteUpdate: Codable {
        var meetingId: Int = 0
        var votePlaceIds: [Int] = []
        var voteTimeIds: [Int] = []
    }
    
    struct FixMeeting: Codable {
        var meetingId: Int = 0
    }
    
    struct GetMeetingResult: Codable {
        var title: String = ""
        var fixedTimes: [String] = []
        var fixedPlace: String = ""
    }
    
    struct GetMeetingsByStatus: Codable {
        var meetingList: [MeetingInfoByStatus] = []
        
        struct MeetingInfoByStatus: Codable {
            var meetingId: Int = 0
            var title: String = ""
            var deadline: String = ""
            var meetingStatus: MeetingStatus = MeetingStatus.CONFIRM
        }
        
        enum MeetingStatus: String, Codable {
            case PENDING
            case CONFIRM
            case END
        }
    }
}
