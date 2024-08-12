//
//  APIModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/9/24.
//

import Foundation



struct ProfileResult {
    
    let memberInfo: MemberInfo
    struct MemberInfo: Codable {
        let name: String
        let phoneNumber: String
        let email: String
    }

    
}
struct CandidatePlace: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}



struct MeetingListResult :Codable  {
    let meetingList: [Meeting]
    struct Meeting: Codable {
        let meetingId: Int
        let title: String
        let deadline: String
        let meetingStatus: String
    }
}


struct MeetingResult :Codable {
    let meetingId: Int

}

// 전체 회의 정보를 나타내는 구조체 정의
struct Meeting: Codable {
    let title: String
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
    let fixedTimes: [String]// 선택적
    let fixedPlace: Place?   // 선택적
    let candidatePlaces: [Place]? // 선택적
    let deadline: String
}

struct Place: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}





struct DetailMeetingResult: Codable {
    let votedTimes: [String]
    let candidatedPlaces: [String]
    let participants: [Participant]
    struct Participant: Codable {
        let name: String
        let avatar: String
    }


}

// APIResponse 구조체 정의

struct VoteInfo: Codable {
    
    let candidateTimes: [String]?
    
    let candidatePlaces: [String]?
}

struct VoteInfoResult: Codable {
    
    let candidateTimeIds: [Int]?
    
    let candidatePlaceIds: [Int]?
}

//미팅 확정도 같음
struct MeetingDetails: Codable {
    let fixedDateTime: [String]
    let fixedPlace: String
}

struct MeetingConfirmed: Codable {
    let fixedDateTime: [String]
    let fixedPlace: String
}






struct VotedTimesResult: Codable {
    let myVotedTimes: [String]
    let totalCandidateTimes: [CandidateTime]
    let numberOfPeople : Int
    struct CandidateTime: Codable {
        let dateTime: String
        let voteCount: Int
    }
}


struct VotedPlacesResult: Codable {
  
        let myVotedPlaces: [String]
        let totalCandidatePlaces: [Place]
        let numberOfPeople : Int
        
        struct CandidatePlace: Codable {
            let title : String         //"title": "Conference Room C",
            let address : String       //                "address": "789 Tertiary Street, Cityville",
            let latitude : Double      // "latitude": 37.7751,
            let longitude : Double     //            "longitude": -122.4196,
            let voteCount : Int        //      "voteCount": 0
        }
}


struct FixedPlace: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}
struct FixedSchedule: Codable {
    
    let fixedTimes: [String]?
    let fixedPlace: FixedPlace?
    
}
struct ResultSchedule: Codable {
    
    let fixedTimes: [String]?
    let fixedPlace: String
    
}


//"timestamp": "2024-01-16T14:20:15.793029167",
//"code": "COMMON200",
//"message": "요청에 성공하였습니다.",
//"result": {
//        "meetingId" : 4
//}

