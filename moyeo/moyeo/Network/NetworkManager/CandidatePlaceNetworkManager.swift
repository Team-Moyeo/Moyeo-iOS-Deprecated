//
//  CandidatePlaceNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class CandidatePlaceNetworkManager: ObservableObject {
    
    // MARK: - 모임 상세 조회(장소)
    @MainActor
    func fetchGetMeetingDetailPlaces(meetingId: Int) async -> CandidatePlaceResponse.GetMeetingDetailPlaces {
        var response = CandidatePlaceResponse.GetMeetingDetailPlaces()
        
        do {
            response = try await getMeetingDetailPlaces(meetingId: meetingId)
            
        } catch {
            print("[fetchGetMeetingDetailPlaces] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingDetailPlaces(meetingId: Int) async throws -> CandidatePlaceResponse.GetMeetingDetailPlaces {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidatePlaces.rawValue + "/\(meetingId)", queryItems: nil)
        
        print("[getMeetingDetailPlaces] url : ", url)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        print("[getMeetingDetailPlaces] request : ", request)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        print("[getMeetingDetailPlaces] data : ", data)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print("[getMeetingDetailPlaces] response : ", response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<CandidatePlaceResponse.GetMeetingDetailPlaces>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
}
