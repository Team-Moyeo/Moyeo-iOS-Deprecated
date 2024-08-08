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
struct ProfileResult: Codable {
    let memberInfo: MemberInfo
}

// APIResponse 구조체 정의
struct ProfileResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: ProfileResult
}


struct CandidatePlace: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}



struct APIResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: [String: String] // 빈 객체를 표현하기 위해 딕셔너리 사용
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
struct DetailMeetingResult: Codable {
    let votedTimes: [String]
    let candidatedPlaces: [String]
    let participants: [Participant]
}

// APIResponse 구조체 정의
struct APIDetailMeetingResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: DetailMeetingResult
}

struct VoteResult: Codable {
    let candidateTimeIds: [Int]
    let candidatePlaceIds: [Int]
}

// APIResponse 구조체 정의
struct APIVoteResponse: Codable {
    let timestamp: String
    let code: String
    let message: String
    let result: VoteResult
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
