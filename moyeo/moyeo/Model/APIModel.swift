//
//  APIModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/9/24.
//

import Foundation

struct MemberInfo: Codable {
    let name: String
    let phoneNumber: String
    let email: String
}

// Result 구조체 정의


// APIResponse 구조체 정의
struct ProfileResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: Result
    
    struct Result: Codable {
        let memberInfo: MemberInfo
    }
}


struct CandidatePlace: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}


struct MeetingListResponse: Codable {
    let timeStamp: String
    let code: String
    let message: String
    let result: Result

    struct Result: Codable {
        let meetingList: [Meeting]
    }

    struct Meeting: Codable {
        let meetingId: Int
        let title: String
        let deadline: String
        let meetingStatus: String
    }
}

//struct APIResponse: Codable {
//    let timestamp: String
//    let code: String
//    let message: String
//    let result: [String: Any] // 빈 객체를 표현하기 위해 딕셔너리 사용
//}

struct MeetingResponse: Codable {
    let timeStamp: String
    let code: String
    let message: String
    let result: Result

    // Result 모델 정의
    struct Result: Codable {
        let meetingId: Int
    }
}
struct APIResponse: Codable {
    let timeStamp: String
    let code: String
    let message: String
    let result: Result
    // Result 모델 정의
    struct Result: Codable {
        let meetingId: Int
//        let votePlaceIDs : [Int]
//        let voteTimeIDs : [Int]
    }
}
// 전체 회의 정보를 나타내는 구조체 정의
struct Meeting: Codable {
    let title: String
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
    let fixedTimes: [String]? // 선택적
    let fixedPlace: Place?    // 선택적
    let candidatePlaces: [Place]? // 선택적
    let deadline: String
}

struct Place: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}

// Participant 구조체 정의
struct Participant: Codable {
    let name: String
    let avatar: String
}

// Result 구조체 정의

// APIResponse 구조체 정의
struct DetailMeetingResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: Result
    
    struct Result: Codable {
        let votedTimes: [String]
        let candidatedPlaces: [String]
        let participants: [Participant]
    }
}


// APIResponse 구조체 정의

struct VoteInfo: Codable {
    
    let candidateTimes: [String]?
    
    let candidatePlaces: [String]?
}

struct VoteResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: Result
    
    struct Result: Codable {
        let candidateTimeIds: [Int]
        let candidatePlaceIds: [Int]
    }

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

struct VotedTimes: Codable {
    let myVotedTimes: [String]
    let totalVotedTimes: [totalCandidateTimes]
    let numberOfPeople : Int
    struct totalCandidateTimes: Codable {
        let dateTime: String
        let voteCount: Int?
    }
}

struct VotedPlaces: Codable {
    let myVotedPlaces: [String]
    let totalCandidatePlaces: [TotalVotedPlace]
    let numberOfPeople : Int
}


// MARK: - TotalVotedTime

// MARK: - TotalVotedPlace
struct TotalVotedPlace: Codable {
    let title: String
    let voteCount: Int
}

// MARK: - Response
struct ResponseVotedTimes: Codable {
    let timeStamp: String
    let code: String
    let message: String
    let result: Result
    struct Result: Codable {
        let myVotedTimes: [String]
        let totalCandidateTimes: [totalCandidateTime]
        let numberOfPeople : Int
        }
    
    struct totalCandidateTime: Codable {
        let dateTime: String
        let voteCount: Int
    }
}


struct ResponseVotedPlaces: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: Result
    
    struct Result: Codable {
        let myVotedPlaces: [String]
        let totalCandidatePlaces: [totalCandidatePlace]
        let numberOfPeople : Int
        
        struct totalCandidatePlace: Codable {
            let title : String         //"title": "Conference Room C",
            let address : String       //                "address": "789 Tertiary Street, Cityville",
            let latitude : Double      // "latitude": 37.7751,
            let longitude : Double     //            "longitude": -122.4196,
            let voteCount : Int        //      "voteCount": 0
        }
    }

}
