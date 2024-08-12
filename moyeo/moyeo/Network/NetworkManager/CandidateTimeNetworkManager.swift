//
//  CandidateTimeNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class CandidateTimeNetworkManager: ObservableObject {
    
    // MARK: - 모임 상세 조회(시간)
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
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidateTimes.rawValue + "/\(meetingId)", queryItems: nil)
        
        print("[getMeetingDetailTimes] url : ", url)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        print("[getMeetingDetailTimes] request : ", request)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        print("[getMeetingDetailTimes] data : ", data)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print("[getMeetingDetailTimes] response : ", response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<CandidateTimeResponse.GetMeetingDetailTimes>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
}
