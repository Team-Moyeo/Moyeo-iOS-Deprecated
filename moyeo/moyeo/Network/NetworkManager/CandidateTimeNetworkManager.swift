//
//  CandidateTimeNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class CandidateTimeNetworkManager: ObservableObject {
    
    @MainActor
    func fetchGetMeetingDetailTimes(request: CandidateTimeRequest.GetMeetingDetailTimes) async -> CandidateTimeResponse.GetMeetingDetailTimes {
        var response = CandidateTimeResponse.GetMeetingDetailTimes()
        
        do {
            response = try await getMeetingDetailTimes(meetingId: request.meetingId)
            
        } catch {
            print("[fetchGetMeetingDetailTimes] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingDetailTimes(meetingId: Int) async throws -> CandidateTimeResponse.GetMeetingDetailTimes {
        NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidateTimes, queryItems: <#T##[URLQueryItem]?#>)
        
        return CandidateTimeResponse.GetMeetingDetailTimes()
    }
    
}
