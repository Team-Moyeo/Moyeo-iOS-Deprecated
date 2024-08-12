//
//  CandidatePlaceResponse.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class CandidatePlaceResponse {
    
    // MARK: - 모임 상세 조회(장소)
    struct GetMeetingDetailPlaces: Codable {
        var myVotedPlaces: [String] = []
        var totalCandidatePlaces: [CandidatePlaceInfo] = []
        var numberOfPeople: Int = 0
    }
            
    struct CandidatePlaceInfo: Codable {
        var title: String = ""
        var address: String = ""
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        var voteCount: Int = 0
    }
    
    struct AddCandidatePlace: Codable {
        var candidatePlaceId: Int = 0
    }
}
